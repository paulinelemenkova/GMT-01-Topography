#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: Benin)
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert

# GMT set up
gmt set FORMAT_GEO_MAP=dddF \
    MAP_FRAME_PEN=dimgray \
    MAP_FRAME_WIDTH=0.1c \
    MAP_TITLE_OFFSET=1c \
    MAP_ANNOT_OFFSET=0.1c \
    MAP_TICK_PEN_PRIMARY=thinner,dimgray \
    MAP_GRID_PEN_PRIMARY=thin,white \
    MAP_GRID_PEN_SECONDARY=thinnest,white \
    FONT_TITLE=12p,Palatino-Roman,black \
    FONT_ANNOT_PRIMARY=7p,0,dimgray \
    FONT_LABEL=7p,0,dimgray \
# Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults

exec bash

# Extract a subset of ETOPO1m for the study area
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R6/20/36/48 -Git1_relief.nc
gmt grdcut GEBCO_2023.nc -R6/20/36/48 -Git_relief.nc
gmt grdinfo -M it_relief.nc
# gdalinfo -stats it_relief.nc
# Topography: actual_range={-3746/1398}

# Make color palette
gmt makecpt -Cgeo -V -T-4151/4655 > pauline.cpt
# elevation etopo1 world elevation dem1 dem2 dem3 globe geo srtm turbo terra earth

#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R6/20/36/48 -JM5.5i -Dh -M -EIT > Italy.txt
#####################################################################

ps=Topo_IT.ps
# Make background transparent image
gmt grdimage it_relief.nc -Cpauline.cpt -R6/20/36/48 -JM5.5i -I+a15+ne0.75 -t40 -Xc -P -K > $ps
    
# Add isolines
gmt grdcontour it1_relief.nc -R -J -C500 -A1000+f7p,26,darkbrown -Wthinner,darkbrown -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thick,dimgray -W0.1p -Df -O -K >> $ps
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thickest,tomato -W0.1p -Df -O -K >> $ps
    
#####################################################################
# CLIPPING
# 1. Start: clip the map by mask to only include country

gmt psclip -R6/20/36/48 -JM5.5i Italy.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage it_relief.nc -Cpauline.cpt -R6/20/36/48 -JM5.5i -I+a15+ne0.75 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour it1_relief.nc -R -J -C500 -Wthinnest,darkbrown -O -K >> $ps
# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thickest,tomato -W0.1p -Df -O -K >> $ps
#gmt pscoast -R -J \
    -Ia/thinner,blue -Na -W0.1p -Df -O -K >> $ps

# 3: Undo the clipping
gmt psclip -C -O -K >> $ps
#####################################################################
    
# Add color legend
gmt psscale -Dg-0.9/5.5+w19.0c/0.15i+v+o0.3/0i+ml+e -R -J -Cpauline.cpt \
    --FONT_LABEL=10p,0,black \
    --FONT_ANNOT_PRIMARY=10p,0,black \
    --FONT_TITLE=10p,0,black \
    -Bg500f50a500+l"Colormap: 'geo' Colors for global bathymetry/topography relief [R=-4151/4655, H, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=wESN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    --MAP_TITLE_OFFSET=0.7c \
    --FONT_ANNOT_PRIMARY=9p,0,black \
    --FONT_LABEL=10p,25,black \
    --FONT_TITLE=13p,0,black \
        -Bpxg2f1a1 -Bpyg2f1a1 -Bsxg2 -Bsyg1 \
    -B+t"Stidy area on the topographic map of Italy" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=12p,0,black \
    --FONT_ANNOT_PRIMARY=12p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx11.7c/-1.7c+c10+w200k+l"Mercator projection. Scale (km)"+f \
    -UBL/0p/-40p -O -K >> $ps

# Texts

#

# insert map
# Countries codes: ISO 3166-1 alpha-2. Continent codes AF (Africa), AN (Antarctica), AS (Asia), EU (Europe), OC (Oceania), NA (North America), or SA (South America). -EEU+ggrey
gmt psbasemap -R -J -O -K -DjBR+w4.5c+o-0.2c/-0.2c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thin,grey -Rg -JG12/40.0N/$w -Da -Glightgoldenrod1 -A5000 -Bga -Wfaint -EIT+gred -Sdodgerblue -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx5.5/-2.0+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y14.0c -N -O \
    -F+f12p,0,black+jLB >> $ps << EOF
0.0 10.0 Data : GEBCO, resolution: 15 arc sec
EOF

# Convert to image file using GhostScript
gmt psconvert Topo_IT.ps -A0.5c -E720 -Tj -Z
