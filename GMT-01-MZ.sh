#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: Mali)
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert
# http://soliton.vm.bytemark.co.uk/pub/cpt-city/esri/hillshade/tn/illumination.png.index.html

exec bash

# Extract a subset of ETOPO1m for the study area
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R29/42/-27/-10 -Gmz1_relief.nc
gmt grdcut GEBCO_2023.nc -R29/42/-27/-10 -Gmz_relief.nc
#gmt gdalinfo -stats mz1_relief.nc
gmt grdinfo -M mz_relief.nc
# -5023/2859

# Make color palette
#gmt makecpt -Cearth -V -T-4430/2533 > pauline.cpt
#gmt makecpt -Cturbo -V -T-4430/2533 > pauline.cpt
#gmt makecpt -Cetopo1 -V -T-4430/2533  > pauline.cpt
#gmt makecpt -Cterra -V -T-4430/2533 > pauline.cpt
gmt makecpt -Cgeo -V -T-5023/2859 > pauline.cpt
#gmt makecpt -Cdem1 -V -T-4430/2533 > pauline.cpt

# gmt makecpt -Cafrikakarte -V -T-3395/1000 > pauline.cpt
# gmt makecpt -Cillumination -V -T-5000/500 -Ic > pauline.cpt
# gmt makecpt -Cwiki-1.02.cpt -V -T-3000/500 > pauline.cpt
# elevation etopo1 world elevation dem1 dem2 dem3 globe geo srtm turbo terra earth

#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R28.5/42/-26.5/-10 -JM6.5i -Dh -M -EMZ > Mozambique.txt
#####################################################################

ps=Topo_MZ.ps
# Make background transparent image
gmt grdimage mz1_relief.nc -Cpauline.cpt -R29/42/-27/-10 -JM6.5i -I+a15+ne0.75 -t40 -Xc -P -K > $ps

# Add isolines
gmt grdcontour mz1_relief.nc -R -J -C500 -A1000+f7p,26,darkbrown -Wthinner,darkbrown -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps
# Add lakes
# gmt pscoast -R -J -Ia/thinner,blue -Na -Sroyalblue1 -W2/thin,blue,0.1p -Df -O -K >> $ps
    
#------------------------->
# CLIPPING
# 1. Start: clip the map by mask to only include country
gmt psclip -R29/42/-27/-10 -JM6.5i Mozambique.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage mz1_relief.nc -Cpauline.cpt -R29/42/-27/-10 -JM6.5i -I+a15+ne0.75 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour mz1_relief.nc -R -J -C500 -A1000+f7p,26,darkbrown -Wthinnest,darkbrown -O -K >> $ps
# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps
# add lakes
#gmt pscoast -R -J -Ia/thinner,blue -Na -Sroyalblue1 -W2/thin,blue,0.1p -Df -O -K >> $ps

# 3: Undo the clipping
gmt psclip -C -O -K >> $ps
#-------------------------<
    
# Add color legend
gmt psscale -Dg27.0/-27+w22.3c/0.15i+v+o0.3/0i+ml+e -R -J -Cpauline.cpt \
    --FONT_LABEL=9p,0,black \
    --FONT_ANNOT_PRIMARY=9p,0,black \
    --FONT_TITLE=8p,0,black \
    -Bg1000f100a1000+l"Colormap: 'geo' - colors for global bathymetry/topography relief [R=-5023/2859, H, C=RGB]" \
    -I0.2 -By+l"m" -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=wEsN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    --MAP_FRAME_PEN=dimgray \
    --MAP_FRAME_WIDTH=0.1c \
    --MAP_TITLE_OFFSET=1.0c \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --FONT_LABEL=8p,25,black \
    --FONT_TITLE=12p,0,black \
        -Bpxg2f1a2 -Bpyg2f1a2 -Bsxg2 -Bsyg1 \
    -B+t"Topographic map of Mozambique" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=9p,0,black \
    --FONT_ANNOT_PRIMARY=9p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx14.5c/-1.3c+c10+w400k+l"Mercator projection. Scale (km)"+f \
    -UBL/0p/-30p -O -K >> $ps

# Study area
# Rotated rectangle. kwargs: -Sjdirection/width/height, coords

# Texts
#
# Study area
# Rotated rectangle. kwargs: -Sjdirection/width/height, coords
gmt psxy -R -J -Sj-13/2.3/2.3 -W1.7p,red -O -K << EOF >> $ps
19.00 -33.00
EOF
#gmt pstext -R -J -N -O -K \
#-F+f11p,0,red+jLB >> $ps << EOF
#19.6 -32.80 Study
#19.6 -33.20 Area
#EOF

# insert map
# Countries codes: ISO 3166-1 alpha-2. Continent codes AF (Africa), AN (Antarctica), AS (Asia), EU (Europe), OC (Oceania), NA (North America), or SA (South America). -EEU+ggrey
gmt psbasemap -R -J -O -K -DjBR+w3.7c+o-0.2c/-0.2c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thinnest,lightgray --MAP_FRAME_PEN=thick,white -Rg -JG35.0/19.0S/$w -Da -Glightgoldenrod1 -A5000 -Bga -Wfaint -EMZ+gred -Sroyalblue1 -O -K -X$x0 -Y$y0 >> $ps
#gmt pscoast -Rg -JG12/5N/$w -Da -Gbrown -A5000 -Bg -Wfaint -ECM+gbisque -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx7.0/-1.8+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y16.5c -N -O \
    -F+f11p,0,black+jLB >> $ps << EOF
2.5 11.0 Digital elevation data: SRTM/GEBCO, 15 arc sec resolution grid
EOF

# Convert to image file using GhostScript
gmt psconvert Topo_MZ.ps -A1.5c -E720 -Tj -Z
