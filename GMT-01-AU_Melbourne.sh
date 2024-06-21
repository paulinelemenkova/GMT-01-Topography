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
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R138/152/-44/-33 -Gau1_relief_M.nc
gmt grdcut GEBCO_2023.nc -R138/152/-44/-33 -Gau_relief_M.nc
gmt grdinfo -M au_relief_M.nc
# gdalinfo -stats au_relief_M.nc

# Make color palette
gmt makecpt -Cetopo1 -V -T-5954/2181 > pauline.cpt
# elevation etopo1 world elevation dem1 dem2 dem3 globe geo srtm turbo terra earth

#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R138/152/-44/-33 -JM6.0i -Dh -M -EAU > Australia.txt
#####################################################################

ps=Topo_AU_M.ps
# Make background transparent image
gmt grdimage au_relief_M.nc -Cpauline.cpt -R138/152/-44/-33 -JM6.0i -I+a15+ne0.75 -t40 -Xc -P -K > $ps
# gmt grdimage au_relief_M.nc -Cpauline.cpt -R138/152/-44/-33 -JM6.0i -I+a15+ne0.75 -t40 -Xc -K > $ps
    
# Add isolines
gmt grdcontour au_relief_M.nc -R -J -C500 -A1000+f6p,26,darkbrown -Wthinnest,darkbrown -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thick,dimgray -W0.1p -Df -O -K >> $ps
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps
    
#####################################################################
# CLIPPING
# 1. Start: clip the map by mask to only include country
gmt psclip -R138/152/-44/-33 -JM6.0i Australia.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage au_relief_M.nc -Cpauline.cpt -R138/152/-44/-33 -JM6.0i -I+a15+ne0.75 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour au1_relief_M.nc -R -J -C250 -A500+f6p,26,darkbrown -Wthinnest,darkbrown -O -K >> $ps
# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps
# Add lakes
gmt pscoast -R -J -Ia/thinner,blue -Na/thicker,deeppink -Sroyalblue1 -W2/thin,blue,0.1p -Df -O -K >> $ps

# 3: Undo the clipping
gmt psclip -C -O -K >> $ps
#####################################################################
    
# Add color legend -R138/152/-44/-33
gmt psscale -Dg135.7/-44+w15.0c/0.15i+v+o0.3/0i+ml+e -R -J -Cpauline.cpt \
    --FONT_LABEL=10p,0,black \
    --FONT_ANNOT_PRIMARY=10p,0,black \
    --FONT_TITLE=10p,0,black \
    -Bg500f50a500+l"Colormap: 'etopo1' Colors for global bathymetry/topography relief [R=-5954/2181, H, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=wESN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    --MAP_TITLE_OFFSET=0.5c \
    --FONT_ANNOT_PRIMARY=9p,0,black \
    --FONT_LABEL=10p,25,black \
    --FONT_TITLE=12p,0,black \
        -Bpxg2f2a2 -Bpyg2f2a2 -Bsxg2 -Bsyg2 \
    -B+t"Location of the Landsat images on the Port Phillip Bay and Melbourne: Victoria, southern Australia" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=10p,0,black \
    --FONT_ANNOT_PRIMARY=10p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx13.0c/-1.7c+c10+w500k+l"Mercator projection. Scale (km)"+f \
    -UBL/0p/-40p -O -K >> $ps
    
# Texts
gmt pstext -R -J -N -O -K \
-F+f18p,31,black+jLB -Gwhite@80 >> $ps << EOF
147.3 -34.9 Canberra
EOF
gmt psxy -R -J -Sa -W0.5p,white -Gyellow1 -O -K << EOF >> $ps
149.13 -35.29 0.70c
EOF
gmt pstext -R -J -N -O -K \
-F+f16p,21,black+jLB -Gwhite@80 >> $ps << EOF
150.5 -33.70 Sydney
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
151.21 -33.86 0.30c
EOF
gmt pstext -R -J -N -O -K \
-F+f16p,21,black+jLB -Gwhite@70 >> $ps << EOF
143.6 -37.65 Melbourne
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
144.96 -37.81 0.30c
EOF
gmt pstext -R -J -N -O -K \
-F+f16p,21,black+jLB >> $ps << EOF
138.75 -35.2 Adelaide
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
138.6 -34.93 0.30c
EOF
gmt pstext -R -J -N -O -K \
-F+f16p,21,black+jLB -Gwhite@80 >> $ps << EOF
149.7 -34.30 Wollongong
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
150.89 -34.43 0.30c
EOF
# geography
gmt pstext -R -J -N -O -K \
-F+jTL+f16p,23,royalblue+jLB >> $ps << EOF
145.0 -39.85 Bass Straight
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f16p,26,white+jLB >> $ps << EOF
138.2 -42.6 I N D I A N
138.2 -43.2 O C E A N
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,26,white+jLB >> $ps << EOF
149.3 -40.3 P A C I F I C
149.4 -40.9 O C E A N
EOF
# rivers
gmt pstext -R -J -N -O -K \
-F+f13p,23,navy+jLB+a35 >> $ps << EOF
144 -34.2 Lachlan
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,23,navy+jLB+a12 >> $ps << EOF
140.3 -34.2 Murray
EOF
# states
gmt pstext -R -J -N -O -K \
-F+jTL+f16p,26,darkred+jLB >> $ps << EOF
143.3 -33.5 NEW SOUTH WALES
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f16p,26,darkred+jLB >> $ps << EOF
142.2 -36.3 VICTORIA
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f16p,26,darkred+jLB >> $ps << EOF
138.1 -33.4 SOUTH
138.1 -33.8 AUSTRALIA
EOF
gmt pstext -R -J -N -O -K \
-F+f16p,26,darkred+jLB -Gwhite@60 >> $ps << EOF
145.35 -42.1 TASMANIA
EOF

# Study area
# Rotated rectangle. kwargs: -Sjdirection/width/height, coords
# Scene Center Long DMS: 144°23'46.54"E; Scene Center Lat DMS: 37°28'27.84"S
gmt psxy -R -J -Sj-13/2.7/2.7 -W1.8p,red -O -K << EOF >> $ps
144.4 -37.5
EOF
# insert map

# Add GMT logo
gmt logo -Dx6.5/-2.1+o0.1i/0.1i+w2c -O -K >> $ps

# Convert to image file using GhostScript
gmt psconvert Topo_AU_M.ps -A2.5c -E720 -Tj -Z
