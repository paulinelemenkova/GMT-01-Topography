#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: Algeria)
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
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R70/137/15/55 -Gcn1_relief.nc
#gmt grdcut GEBCO_2023.nc -R70/137/15/55 -Gcn_relief.nc
gmt grdinfo -M cn1_relief.nc
# Minimum=-7795.000, Maximum=8271.000, Mean=332.901, StdDev=802.901

# Make color palette
#gmt makecpt -Cterra -V -T-7795/8271 > pauline.cpt
gmt makecpt -Cturbo -V -T-7795/8271 > pauline.cpt
#gmt makecpt -Cturbo -V -T-5141/4038 > pauline.cpt
# elevation etopo1 world elevation dem1 dem2 dem3 globe geo srtm turbo terra earth

#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R70/137/15/55 -JM6.5i -Dh -M -ECN > CN.txt
#####################################################################

ps=Topo_CN.ps
# Make background transparent image

gmt grdimage cn1_relief.nc -Cpauline.cpt -R70/137/15/55 -JM6.5i -I+a15+ne0.75 -t70 -Xc -P -K > $ps

# Add isolines
gmt grdcontour cn1_relief.nc -R -J -C2000 -Wthinnest,darkbrown -O -K >> $ps

# Add coastlines, borders, rivers, lakes
gmt pscoast -R -J -Ia/thinnest,blue -Na -N1/thick,tomato -W0.1p -Df -O -K >> $ps
    
#####################################################################
# CLIPPING
# 1. Start: clip the map by mask to only include country

gmt psclip -R70/137/15/55 -JM6.5i CN.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage cn1_relief.nc -Cpauline.cpt -R70/137/15/55 -JM6.5i -I+a15+ne0.75 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour cn1_relief.nc -R -J -C2000 -Wthinnest,darkbrown -O -K >> $ps
# Add coastlines, borders, rivers, lakes
gmt pscoast -R -J -Ia/thinnest,blue -Na -N1/thick,tomato -W0.1p -Df -O -K >> $ps
# Add lakes
gmt pscoast -R -J -Ia/thinner,blue -Na -Sroyalblue1 -W2/thin,blue,0.1p -Df -O -K >> $ps

# 3: Undo the clipping
gmt psclip -C -O -K >> $ps
#####################################################################
    
# Add color legend -R70/137/15/55
gmt psscale -Dg70/10+w16.0c/0.15i+h+o0.3/0i+ml+e -R -J -Cpauline.cpt \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --FONT_TITLE=8p,0,black \
    -Bg2000f100a2000+l"Colormap: 'Turbo' Google's Improved Rainbow Colormap for Visualization [R=-7795/8271, H, C=RGB]" \
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
    -Bpxf5a10g5 -Bpyg5f5a10 -Bsxg5 -Bsyg5 \
    -B+t"Topographic map of China" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=9p,0,black \
    --FONT_ANNOT_PRIMARY=9p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx14.5c/-2.5c+c10+w2000k+l"Mercator Projection. Scale (km)"+f \
    -UBL/0p/-70p -O -K >> $ps

# Texts
# Study area
# Rotated rectangle. kwargs: -Sjdirection/width/height, coords
# LAT: 90.64N LON: 30.31W
gmt psxy -R -J -Sj-13/0.5/0.5 -W1.0p,yellow -O -K << EOF >> $ps
90.64 30.31
EOF

# Texts
# Cities -R-15/0/27/37
gmt pstext -R -J -N -O -K \
-F+f10p,0,ivory+jLB >> $ps << EOF
92.00 29.45 Lhasa
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
91.12 29.65 0.15c
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,0,black+jLB >> $ps << EOF
115.10 40.60 Beijing
EOF
gmt psxy -R -J -Sa -W0.5p,red -Gred -O -K << EOF >> $ps
116.39 39.90 0.35c
EOF
# countries
gmt pstext -R -J -N -O -K \
-F+f18p,31,ivory+jLB >> $ps << EOF
86.0 36.0 C         H         I         N         A
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB >> $ps << EOF
96.5 46.0 M   O   N   G   O   L   I   A
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB >> $ps << EOF
108.5 52.0 R  U  S  S  I  A
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB+a60 -Gwhite@60>> $ps << EOF
71.0 30.0 PAKISTAN
EOF
gmt pstext -R -J -N -O -K \
-F+f8p,0,black+jLB >> $ps << EOF
125.5 40.0 NORTH
125.5 39.1 KOREA
EOF
gmt pstext -R -J -N -O -K \
-F+f8p,0,black+jLB >> $ps << EOF
127.0 36.9 SOUTH
127.0 36.0 KOREA
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,0,black+jLB -Gwhite@50 >> $ps << EOF
132.0 34.1 JAPAN
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,0,black+jLB >> $ps << EOF
70.20 45.2 KAZAKHSTAN
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,0,black+jLB -Gwhite@60 >> $ps << EOF
71.00 41.5 KYRGYZSTAN
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB >> $ps << EOF
74.0 23.0 I    N    D    I    A
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,0,black+jLB+a-20 -Gwhite@60 >> $ps << EOF
82.0 28.6 NEPAL
EOF
gmt pstext -R -J -N -O -K \
-F+f8p,0,black+jLB -Gwhite@60 >> $ps << EOF
89.0 27.0 BHUTAN
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB >> $ps << EOF
93.3 20.5 MYANMAR
EOF
gmt pstext -R -J -N -O -K \
-F+f8p,0,black+jLB >> $ps << EOF
99.0 15.9 THAILAND
EOF
gmt pstext -R -J -N -O -K \
-F+f8p,0,black+jLB -Gwhite@60 >> $ps << EOF
87.0 23.0 BANGLADESH
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,0,black+jLB+a-43 >> $ps << EOF
102.0 20.0 L A O S
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,0,black+jLB -Gwhite@60 >> $ps << EOF
103.0 21.2 VIETNAM
EOF
# insert map
gmt psbasemap -R -J -O -K -DjTL+w3.2c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thin,grey --MAP_FRAME_PEN=thin,azure -Rg -JG100/30N/$w -Da -Glightgoldenrod1 -A5000 -Bga -Wfaint -ECN+gred -Sroyalblue3 -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx7.0/-3.1+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y6.3c -N -O \
    -F+f10p,0,black+jLB >> $ps << EOF
3.0 10.4 Digital elevation data: SRTM/GEBCO, 15 arc sec resolution grid
EOF

# Convert to image file using GhostScript
gmt psconvert Topo_CN.ps -A0.5c -E720 -Tj -Z
