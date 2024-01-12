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
gmt makecpt -Cgeo -V -T-7795/8271 > pauline.cpt
#gmt makecpt -Cturbo -V -T-5141/4038 > pauline.cpt
# elevation etopo1 world elevation dem1 dem2 dem3 globe geo srtm turbo terra earth


#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R70/137/15/55 -JU47.5/6.5i -Dh -M -ECN > CN.txt
#####################################################################

ps=Topo_CN.ps
# Make background transparent image

gmt grdimage cn1_relief.nc -Cpauline.cpt -R70/137/15/55 -JU47.5/6.5i -I+a15+ne0.75 -t70 -Xc -P -K > $ps

# Add isolines
gmt grdcontour cn1_relief.nc -R -J -C2000 -Wthinnest,darkbrown -O -K >> $ps

# Add coastlines, borders, rivers, lakes
gmt pscoast -R -J -Ia/thinnest,blue -Na -N1/thick,tomato -W0.1p -Df -O -K >> $ps
    
#####################################################################
# CLIPPING
# 1. Start: clip the map by mask to only include country

gmt psclip -R70/137/15/55 -JU47.5/6.5i CN.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage cn1_relief.nc -Cpauline.cpt -R70/137/15/55 -JU47.5/6.5i -I+a15+ne0.75 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour cn1_relief.nc -R -J -C2000 -Wthinnest,darkbrown -O -K >> $ps
# Add coastlines, borders, rivers, lakes
gmt pscoast -R -J -Ia/thinnest,blue -Na -N1/thick,tomato -W0.1p -Df -O -K >> $ps

# 3: Undo the clipping
gmt psclip -C -O -K >> $ps
#####################################################################
    
# Add color legend -R70/137/15/55
gmt psscale -Dg70/8.5+w16.0c/0.15i+h+o0.3/0i+ml+e -R -J -Cpauline.cpt \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --FONT_TITLE=8p,0,black \
    -Bg2000f100a2000+l"Colormap: 'geo' [R=-7795/8271, H, C=RGB]; transparence des régions voisines : 70%" \
    -I0.2 -By+lm -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=WEsN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    --MAP_TICK_PEN_PRIMARY=thinner,dimgray \
    --MAP_FRAME_WIDTH=0.1c \
    --MAP_TITLE_OFFSET=-0.3c \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --FONT_LABEL=8p,25,black \
    --FONT_TITLE=12p,0,black \
    -Bpxf5a10g5 -Bpyg5f5a10 -Bsxg5 -Bsyg5 \
    -B+t"Carte générale de la Chine" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=9p,0,black \
    --FONT_ANNOT_PRIMARY=9p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx14.5c/-2.5c+c10+w2000k+l"Projection UTM, Zone 47.5, échelle (km)"+f \
    -UBL/0p/-70p -O -K >> $ps

# Study area
# Rotated rectangle. kwargs: -Sjdirection/width/height, coords
# LAT: 34°36'38.05"N LON: 5°32'33.07"W
gmt psxy -R -J -Sj-13/0.5/0.5 -W1.0p,yellow -O -K << EOF >> $ps
114.00 30.30
EOF

# Texts
# Cities -R-15/0/27/37
gmt pstext -R -J -N -O -K \
-F+f9p,0,ivory+jLB >> $ps << EOF
114.85 31.6 Wuhan
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
114.30 30.59 0.15c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,ivory+jLB >> $ps << EOF
111.70 41.30 Beijing
EOF
gmt psxy -R -J -Sa -W0.5p,red -Gred -O -K << EOF >> $ps
116.39 39.90 0.35c
EOF

# insert map
gmt psbasemap -R -J -O -K -DjTL+w3.2c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thinner,white --MAP_FRAME_PEN=thin,azure -Rg -JG100/30N/$w -Da -Glightgoldenrod1 -A5000 -Bga -Wfaint -ECN+gred -Sroyalblue3 -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx7.0/-3.1+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y6.0c -N -O \
    -F+f9p,0,black+jLB >> $ps << EOF
6.0 7.0 et zone d'études (Wuhan)
EOF

# Convert to image file using GhostScript
gmt psconvert Topo_CN.ps -A0.5c -E720 -Tj -Z
