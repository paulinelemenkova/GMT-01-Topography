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
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R77/103/25/40 -Gcn1_tibet_relief.nc
gmt grdcut GEBCO_2023.nc -R77/103/25/40 -Gcn_tibet_relief.nc
gmt grdinfo -M cn1_tibet_relief.nc
# Minimum=2.000, Maximum=8271.000, Mean=332.901, StdDev=802.901

# Make color palette
#gmt makecpt -Cterra -V -T-7795/8271 > pauline.cpt
#gmt makecpt -Cturbo -V -T2/8271 > pauline.cpt
#gmt makecpt -Cdem -V -T2/8271 > pauline.cpt
#gmt makecpt -Cterra -V -T2/8271 > pauline.cpt
gmt makecpt -Cdem1 -V -T2/8271 > pauline.cpt
#gmt makecpt -Cturbo -V -T-5141/4038 > pauline.cpt
# elevation etopo1 world elevation dem1 dem2 dem3 globe geo srtm turbo terra earth

#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R77/103/25/40 -JM6.5i -Dh -M -ECN > CN.txt
#####################################################################

ps=Topo_CN_Tibet.ps
# Make background transparent image

gmt grdimage cn_tibet_relief.nc -Cpauline.cpt -R77/103/25/40 -JM6.5i -I+a15+ne0.75 -Xc -P -K > $ps
# Add isolines
gmt grdcontour cn1_tibet_relief.nc -R -J -C2000 -Wthinnest,darkbrown -O -K >> $ps
# Add coastlines, borders, rivers, lakes
gmt pscoast -R -J -Ia/thinnest,blue -Na -N1/thick,tomato -W0.1p -Df -O -K >> $ps
# Add lakes
gmt pscoast -R -J -Ia/thinner,blue -Na -Sroyalblue1 -W2/thin,blue,0.1p -Df -O -K >> $ps
    
# Add color legend -R77/103/25/40
gmt psscale -Dg76.5/23.5+w16.5c/0.15i+h+o0.3/0i+ml+e -R -J -Cpauline.cpt \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --FONT_TITLE=8p,0,black \
    -Bg1000f100a1000+l"Colormap: 'DEM1' Digital Elevation Model scale [R=2/8271, H, C=RGB]" \
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
    -B+t"Digital Elevation Model (DEM) relief of the Tibetan Plateau, China" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=9p,0,black \
    --FONT_ANNOT_PRIMARY=9p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx14.5c/-2.5c+c10+w500k+l"Mercator Projection. Scale (km)"+f \
    -UBL/0p/-60p -O -K >> $ps

#gmt psxy -R -J ridge.gmt -Sf0.5c/0.15c+l+t -Wthin,yellow -Gpurple -O -K >> $ps
#gmt psxy -R -J TP_Indian.txt -L -Wthickest,red -O -K >> $ps
#gmt psxy -R -J TP_Eurasian.txt -L -Wthickest,red -O -K >> $ps

# Texts

gmt pstext -R -J -N -O -K \
-F+f18p,2,cornsilk+jLB >> $ps << EOF
81.50 33.00 T  I  B  E  T  A  N     P  L  A  T  E  A  U
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,0,cornsilk+jLB >> $ps << EOF
81.30 39.00 Taklamakan Desert
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,yellow+jLB >> $ps << EOF
89.70 29.85 Lhasa
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
91.12 29.65 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,0,cornsilk+jLB+a25 -Gdarkgoldenrod4@60 >> $ps << EOF
82.00 35.50 Kunlun Mountains
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,0,cornsilk+jLB+a-45 -Gdarkgoldenrod4@60 >> $ps << EOF
77.00 35.00 Karakoram
EOF
gmt pstext -R -J -N -O -K \
-F+f16p,6,cornsilk+jLB+a-16 -Gdarkgoldenrod4@70 >> $ps << EOF
83.00 29.00 H  I  M  A  L  A  Y  A
EOF
gmt pstext -R -J -N -O -K \
-F+f14p,0,cornsilk+jLB+a-30 -Gdarkgoldenrod4@60 >> $ps << EOF
97.00 39.00 Qilian Mountains
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,6,paleturquoise1+jLB+a-5 >> $ps << EOF
85.50 25.60 Ganges
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,6,paleturquoise1+jLB+a14 >> $ps << EOF
91.00 26.30 Brahmaputra
EOF
# Texts
# Study area
# Rotated rectangle. kwargs: -Sjdirection/width/height, coords
# LAT: 90.64N LON: 30.31W
gmt psxy -R -J -Sj-13/1.5/1.5 -W1.0p,yellow -O -K << EOF >> $ps
90.64 30.31
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,azure+jLB >> $ps << EOF
91.00 30.45 Lake Nam Co
EOF

# Add GMT logo
gmt logo -Dx6.7/-3.0+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y3.5c -N -O \
    -F+f10p,0,black+jLB >> $ps << EOF
3.0 13.0 Digital elevation data: SRTM/GEBCO, 15 arc sec resolution grid
EOF

# Convert to image file using GhostScript
gmt psconvert Topo_CN_Tibet.ps -A0.5c -E720 -Tj -Z
