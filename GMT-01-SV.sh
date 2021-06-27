#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO dataset (here: El Salvador)
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
    FONT_ANNOT_PRIMARY=7p,Helvetica,dimgray \
    FONT_LABEL=7p,Helvetica,dimgray
# Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults

chsh -s /bin/bash

chsh -s /bin/zsh

gmt grdcut GEBCO_2019.nc -R269.5/272.5/13.0/14.5 -Gsv_relief.nc
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R269.5/272.5/13.0/14.5 -Gsv_relief1.nc

gdalinfo sv_relief.nc -stats
# Min=-6644.000 Max=3739.000

#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R269.5/272.5/13.0/14.5 -Dh -M -ESV > sv.txt
#####################################################################

# Make color palette
# makecpt --help
#gmt makecpt -Cgeo.cpt -V -T-6644/3739 > pauline.cpt
gmt makecpt -Cgeo.cpt -V -T-1000/3739 > pauline.cpt

# Generate a file
ps=Topography_SV.ps
# Make background transparent image
gmt grdimage sv_relief.nc -Cpauline.cpt -R269.5/272.5/13.0/14.5 -JM6.0i -P -I+a15+ne0.75 -t50 -Xc -K > $ps
    
# Add isolines
gmt grdcontour sv_relief1.nc -R -J -C50 -W0.1p -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P \
    -Ia/thinner,blue -Na -N1/thicker,darkred -W0.1p -Df -O -K >> $ps
    
#####################################################################
# CLIPPING
# 1. Start: clip the map by mask to only include country

gmt psclip -R269.5/272.5/13.0/14.5 -JM6.0i sv.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage sv_relief.nc -Cpauline.cpt -R269.5/272.5/13.0/14.5 -JM6.0i -I+a15+ne0.75 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour sv_relief1.nc -R -J -C50 -Wthinnest,darkbrown -O -K >> $ps
# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,darkred -W0.1p -Df -O -K >> $ps

# 3: Undo the clipping
gmt psclip -C -O -K >> $ps
#####################################################################

# Add color barlegend
gmt psscale -Dg269.5/12.77+w15.3c/0.4c+h+o0.0/0i+ml -R -J -Cpauline.cpt \
    --FONT_LABEL=8p,Helvetica,black \
    --MAP_LABEL_OFFSET=0.1c \
    --FONT_ANNOT_PRIMARY=6p,0,black \
    -Baf+l"Color scale 'geo': global bathymetry/topography relief [R=-6857/3206, H=0, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=WEsN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    -Bpx1f0.25a0.5 -Bpyg1f0.25a0.5 -Bsxg0.5 -Bsyg0.5 \
    --MAP_TITLE_OFFSET=0.6c \
    --FONT_TITLE=13p,0,black \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    -B+t"Topographic map of El Salvador" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=6p,0,black \
    --MAP_LABEL_OFFSET=0.1c \
    -Lx12.8c/-2.1c+c50+w50k+l"Mercator projection. Scale: km"+f \
    -UBL/-5p/-60p -O -K >> $ps
    
# Texts

# insert map
# Countries codes: ISO 3166-1 alpha-2. Continent codes AF (Africa), AN (Antarctica), AS (Asia), EU (Europe), OC (Oceania), NA (North America), or SA (South America). -EEU+ggrey
gmt psbasemap -R -J -O -K -DjBL+w2.7c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thin,grey -Rg -JG270/16N/$w -Da -Gbrown -A5000 -Bg -Wfaint -ESA+gpeachpuff -ESV+gyellow -Sskyblue1 -O -K -X$x0 -Y$y0 >> $ps
#gmt pscoast -Rg -JG12/5N/$w -Da -Gbrown -A5000 -Bg -Wfaint -ECM+gbisque -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx6.2/-2.9+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y1.1c -N -O \
    -F+f11p,0,black+jLB >> $ps << EOF
1.5 11.0 SRTM/GEBCO 15 arc sec resolution global terrain model grid
EOF

# Convert to image file using GhostScript
gmt psconvert Topography_SV.ps -A0.5c -E720 -Tj -Z
