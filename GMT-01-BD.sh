#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: India)
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert

exec bash

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

# Extract a subset of ETOPO1m for the study area
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R65/100/5/36 -Gin1_relief.nc
#gmt grdcut GEBCO_2023.nc -R65/100/5/36 -Gin_relief.nc
gmt grdinfo -M in1_relief.nc
# Minimum=-5398.000, Maximum=8271.000

# Make color palette
#gmt makecpt -Cterra -V -T-7795/8271 > pauline.cpt
gmt makecpt -Cgeo -V -T-5398/8271 > pauline.cpt
#gmt makecpt -Cturbo -V -T-5141/4038 > pauline.cpt
# elevation etopo1 world elevation dem1 dem2 dem3 globe geo srtm turbo terra earth

#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R65/100/5/36 -JM6.5i -Dh -M -EIN > IN.txt
#####################################################################

ps=Topo_IN.ps
# Make background transparent image

gmt grdimage in1_relief.nc -Cpauline.cpt -R65/100/5/36 -JM6.5i -I+a15+ne0.75 -t50 -Xc -P -K > $ps

# Add isolines
gmt grdcontour in1_relief.nc -R -J -C2000 -Wthinnest,darkbrown -O -K >> $ps

# Add coastlines, borders, rivers, lakes
gmt pscoast -R -J -Ia/thinnest,blue -Na -N1/thick,tomato -W0.1p -Df -O -K >> $ps

#####################################################################
# CLIPPING
# 1. Start: clip the map by mask to only include country

gmt psclip -R65/100/5/36 -JM6.5i IN.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage in1_relief.nc -Cpauline.cpt -R65/100/5/36 -JM6.5i -I+a15+ne0.75 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour in1_relief.nc -R -J -C2000 -Wthinnest,darkbrown -O -K >> $ps
# Add coastlines, borders, rivers, lakes
gmt pscoast -R -J -Ia/thinnest,blue -Na -N1/thick,tomato -W0.1p -Df -O -K >> $ps
# Add lakes
gmt pscoast -R -J -Ia/thinner,blue -Na -Sroyalblue1 -W2/thin,blue,0.1p -Df -O -K >> $ps

# 3: Undo the clipping
gmt psclip -C -O -K >> $ps
#####################################################################
    
# Add color legend -R65/100/5/36
gmt psscale -Dg65/2.5+w16.0c/0.15i+h+o0.3/0i+ml+e -R -J -Cpauline.cpt \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --FONT_TITLE=8p,0,black \
    -Bg2000f100a2000+l"Colormap: 'geo' colormap for topography [R=-5398/8271, H, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=WEsN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    --MAP_TICK_PEN_PRIMARY=thinner,dimgray \
    --MAP_FRAME_WIDTH=0.1c \
    --MAP_TITLE_OFFSET=0.7c \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --FONT_LABEL=8p,25,black \
    --FONT_TITLE=13p,0,black \
    -Bpxf5a5g5 -Bpyg5f5a5 -Bsxg5 -Bsyg5 \
    -B+t"Topographic map of India" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=9p,0,black \
    --FONT_ANNOT_PRIMARY=9p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx14.5c/-2.5c+c10+w1000k+l"Mercator Projection. Scale (km)"+f \
    -UBL/0p/-70p -O -K >> $ps

# Texts
# countries
gmt pstext -R -J -N -O -K \
-F+f16p,31,ivory+jLB >> $ps << EOF
73.0 22.0 I         N         D         I         A
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,0,black+jLB >> $ps << EOF
66.0 29.0 P A K I S T A N
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,0,black+jLB >> $ps << EOF
87.0 32.0 C  H  I  N  A
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,0,black+jLB >> $ps << EOF
93.5 21.0 T H A I L A N D
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,0,black+jLB+a-25 -Gwhite@60>> $ps << EOF
82.0 29.0 N E P A L
EOF
gmt pstext -R -J -N -O -K \
-F+f8p,0,black+jLB >> $ps << EOF
88.1 24.5 BANGLADESH
EOF
gmt pstext -R -J -N -O -K \
-F+f8p,0,black+jLB -Gwhite@60 >> $ps << EOF
89.3 27.0 BHUTAN
EOF
gmt pstext -R -J -N -O -K \
-F+f8p,0,black+jLB >> $ps << EOF
80.1 7.9 SRI
80.1 7.0 LANKA
EOF
# water
gmt pstext -R -J -N -O -K \
-F+jTL+f16p,23,white+jLB >> $ps << EOF
#83.3 6.3 I N D I A N   O C E A N
68.3 6.3 I     N     D     I     A     N
83.3 6.3 O     C     E     A     N
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,26,blue+jLB >> $ps << EOF
86.3 13.0 Bay of
86.3 12.1 Bengal
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,26,blue+jLB >> $ps << EOF
66.0 13.0 Arabian
67.0 12.1 Sea
EOF
# Study area
# Rotated rectangle. kwargs: -Sjdirection/width/height, coords
# LAT: 20°13'46.99"N LON: 85°02'54.24"E
gmt psxy -R -J -Sj-13/1.0/1.0 -W1.0p,yellow -O -K << EOF >> $ps
85.05 20.23
EOF

# Texts
# insert map
gmt psbasemap -R -J -O -K -DjTL+w3.2c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thin,grey --MAP_FRAME_PEN=thin,azure -Rg -JG80/20N/$w -Da -Glightgoldenrod1 -A5000 -Bga -Wfaint -EIN+gred -Sroyalblue3 -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx7.0/-3.1+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y9.6c -N -O \
    -F+f10p,0,black+jLB >> $ps << EOF
3.0 10.4 Digital elevation data: SRTM/GEBCO, 15 arc sec resolution grid
EOF

# Convert to image file using GhostScript
gmt psconvert Topo_IN.ps -A0.5c -E720 -Tj -Z
