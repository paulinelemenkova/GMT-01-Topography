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
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R87/93/20/27 -Gbd1_relief.nc
gmt grdcut GEBCO_2023.nc -R87/93/20/27 -Gbd_relief.nc
gmt grdinfo -M bd1_relief.nc
# Minimum=-1485.000, Maximum=3592.000

# Make color palette
#gmt makecpt -Cterra -V -T-1000/1500 > pauline.cpt
gmt makecpt -Cetopo1 -V -T-1000/1500 > pauline.cpt
#gmt makecpt -Cgeo -V -T-1485/3592 > pauline.cpt
#gmt makecpt -Cturbo -V -T-1485/3592 > pauline.cpt
# elevation etopo1 world elevation dem1 dem2 dem3 globe geo srtm turbo terra earth

#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R87/93/20/27 -JM6.5i -Dh -M -EBD > BD.txt
#####################################################################

ps=Topo_BD.ps
# Make background transparent image

gmt grdimage bd_relief.nc -Cpauline.cpt -R87/93/20/27 -JM6.5i -I+a15+ne0.75 -t50 -Xc -P -K > $ps

# Add isolines
gmt grdcontour bd1_relief.nc -R -J -C200 -Wthinnest,darkbrown -O -K >> $ps

# Add coastlines, borders, rivers, lakes
gmt pscoast -R -J -Ia/thinnest,blue -Na -N1/thick,tomato -W0.1p -Df -O -K >> $ps

#####################################################################
# CLIPPING
# 1. Start: clip the map by mask to only include country

gmt psclip -R87/93/20/27 -JM6.5i BD.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage bd_relief.nc -Cpauline.cpt -R87/93/20/27 -JM6.5i -I+a15+ne0.75 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour bd1_relief.nc -R -J -C200 -Wthinnest,darkbrown -O -K >> $ps
# Add coastlines, borders, rivers, lakes
gmt pscoast -R -J -Ia/thinnest,blue -Na -N1/thick,tomato -W0.1p -Df -O -K >> $ps
# Add lakes
gmt pscoast -R -J -Ia/thinner,blue -Na -Sroyalblue1 -W2/thin,blue,0.1p -Df -O -K >> $ps

# 3: Undo the clipping
gmt psclip -C -O -K >> $ps
#####################################################################
    
# Add color legend -R87/93/20/27
gmt psscale -Dg87/19.5+w16.0c/0.15i+h+o0.3/0i+ml+e -R -J -Cpauline.cpt \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --FONT_TITLE=8p,0,black \
    -Bg2000f100a2000+l"Colormap: 'etopo1' colormap for topography [R=-1000/1500, H, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=WEsN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    --MAP_TICK_PEN_PRIMARY=thinner,dimgray \
    --MAP_FRAME_WIDTH=0.1c \
    --MAP_TITLE_OFFSET=0.7c \
    --FONT_ANNOT_PRIMARY=10p,0,black \
    --FONT_LABEL=12p,25,black \
    --FONT_TITLE=14p,0,black \
    -Bpxf2a1g1 -Bpyf2a1g1 -Bsxg2 -Bsyg2 \
    -B+t"Topographic map of Banglaldesh" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=11p,0,black \
    --FONT_ANNOT_PRIMARY=11p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx14.5c/-2.5c+c10+w200k+l"Mercator Projection. Scale (km)"+f \
    -UBL/0p/-70p -O -K >> $ps

# Texts
# countries
gmt pstext -R -J -N -O -K \
-F+f16p,0,black+jLB >> $ps << EOF
87.3 23.5 I  N  D  I  A
EOF
gmt pstext -R -J -N -O -K \
-F+f16p,0,black+jLB >> $ps << EOF
92.1 24.1 I N D I A
EOF
gmt pstext -R -J -N -O -K \
-F+f16p,0,black+jLB >> $ps << EOF
87.2 26.6 N E P A L
EOF
gmt pstext -R -J -N -O -K \
-F+f16p,0,ivory+jLB >> $ps << EOF
89.1 24.3 B A N G L A D E S H
EOF
gmt pstext -R -J -N -O -K \
-F+f14p,0,black+jLB -Gwhite@60 >> $ps << EOF
89.6 26.85 B H U T A N
EOF
gmt pstext -R -J -N -O -K \
-F+f14p,0,black+jLB -Gwhite@60 >> $ps << EOF
92.1 21.1 MYANMAR
EOF
# water
gmt pstext -R -J -N -O -K \
-F+jTL+f18p,23,royalblue1+jLB >> $ps << EOF
87.3 20.4 I   N   D   I   A   N               O   C   E   A   N
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f18p,2,royalblue1+jLB >> $ps << EOF
90.3 21.1 Bay of Bengal
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,0,mintcream+jLB >> $ps << EOF
90.47 23.73 Dhaka
EOF
gmt psxy -R -J -Sc -W0.5p -Gred -O -K << EOF >> $ps
90.39 23.76 0.30c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,white+jLB+a-30 >> $ps << EOF
89.90 23.5 Ganges
EOF

# Study area
# Rotated rectangle. kwargs: -Sjdirection/width/height, coords
# LAT: 23°06'46.30"N LON: 90°23'11.90"E
gmt psxy -R -J -Sj-13/5.0/5.0 -W2.0p,yellow -O -K << EOF >> $ps
90.39 23.11
EOF
gmt pstext -R -J -N -O -K \
    -F+f13p,2,yellow+jLB >> $ps << EOF
89.8 23.10 S t u d y     A r e a
EOF

# Texts
# insert map
gmt psbasemap -R -J -O -K -DjTR+w4.5c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thin,grey --MAP_FRAME_PEN=thin,azure -Rg -JG80/20N/$w -Da -Glightgoldenrod1 -A5000 -Bga -Wfaint -EBD+gred -Sroyalblue3 -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx7.0/-3.1+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y14.8c -N -O \
    -F+f12p,0,black+jLB >> $ps << EOF
1.0 10.4 Digital elevation data: SRTM/GEBCO, 15 arc sec resolution grid
EOF

# Convert to image file using GhostScript
gmt psconvert Topo_BD.ps -A0.5c -E720 -Tj -Z
