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
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R110/160/-45/-10 -Gau1_relief.nc
gmt grdcut GEBCO_2023.nc -R110/160/-45/-10 -Gau_relief.nc
gmt grdinfo -M au_relief.nc
# gdalinfo -stats au_relief.nc

# Make color palette
gmt makecpt -Cgeo -V -T-7329/2735 > pauline.cpt
# elevation etopo1 world elevation dem1 dem2 dem3 globe geo srtm turbo terra earth

#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R110/160/-45/-10 -JM6.5i -Dh -M -EAU > Australia.txt
#####################################################################

ps=Topo_AU.ps
# Make background transparent image
gmt grdimage au1_relief.nc -Cpauline.cpt -R110/160/-45/-10 -JM6.5i -I+a15+ne0.75 -t40 -Xc -K > $ps
    
# Add isolines
gmt grdcontour au1_relief.nc -R -J -C1000 -A1000+f6p,26,darkbrown -Wthinnest,darkbrown -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thick,dimgray -W0.1p -Df -O -K >> $ps
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps
    
#####################################################################
# CLIPPING
# 1. Start: clip the map by mask to only include country
gmt psclip -R110/160/-45/-10 -JM6.5i Australia.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage au1_relief.nc -Cpauline.cpt -R110/160/-45/-10 -JM6.5i -I+a15+ne0.75 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour au1_relief.nc -R -J -C1000 -Wthinnest,darkbrown -O -K >> $ps
# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps
# Add lakes
gmt pscoast -R -J -Ia/thinner,blue -Na/thicker,yellow -Sroyalblue1 -W2/thin,blue,0.1p -Df -O -K >> $ps

# 3: Undo the clipping
gmt psclip -C -O -K >> $ps
#####################################################################
    
# Add color legend -R110/160/-45/-10
gmt psscale -Dg102/-45+w13.0c/0.15i+v+o0.3/0i+ml+e -R -J -Cpauline.cpt \
    --FONT_LABEL=10p,0,black \
    --FONT_ANNOT_PRIMARY=10p,0,black \
    --FONT_TITLE=10p,0,black \
    -Bg500f50a500+l"Colormap: 'geo' Colors for global bathymetry/topography relief [R=-7329/2735, H, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=wESN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    --MAP_TITLE_OFFSET=0.7c \
    --FONT_ANNOT_PRIMARY=9p,0,black \
    --FONT_LABEL=10p,25,black \
    --FONT_TITLE=12p,0,black \
        -Bpxg2f2a4 -Bpyg2f2a4 -Bsxg4 -Bsyg4 \
    -B+t"Topographic map of Australia with location of the study area" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=11p,0,black \
    --FONT_ANNOT_PRIMARY=10p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx14.0c/-1.7c+c10+w1000k+l"Mercator projection. Scale (km)"+f \
    -UBL/0p/-40p -O -K >> $ps
    
# Texts
gmt pstext -R -J -N -O -K \
-F+f12p,22,azure2+jLB >> $ps << EOF
149.20 -35.35 Canberra
EOF
gmt psxy -R -J -Sa -W0.5p -Gred -O -K << EOF >> $ps
149.13 -35.29 0.40c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,21,lightyellow+jLB >> $ps << EOF
151.25 -33.90 Sydney
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
151.21 -33.86 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,21,lightyellow+jLB >> $ps << EOF
144.96 -37.85 Melbourne
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
144.96 -37.81 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,21,lightyellow+jLB >> $ps << EOF
153.08 -27.40 Brisbane
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
153.03 -27.47 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,21,lightyellow+jLB >> $ps << EOF
116.0 -32.00 Perth
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
115.86 -31.95 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,21,lightyellow+jLB >> $ps << EOF
139.2 -35.2 Adelaide
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
138.6 -34.93 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,21,lightyellow+jLB >> $ps << EOF
153.6 -28.2 Gold Coast
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
153.4 -28.02 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,21,lightyellow+jLB >> $ps << EOF
151.80 -33.0 Newcastle
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
151.75 -32.93 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,21,lightyellow+jLB >> $ps << EOF
150.95 -34.50 Wollongong
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
150.89 -34.43 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,21,lightyellow+jLB >> $ps << EOF
153.20 -26.70 Sunshine Coast
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
153.09 -26.65 0.20c
EOF
# geography
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,23,white+jLB -Groyalblue@90 >> $ps << EOF
125.3 -35.5 Great Australian
128.1 -36.5 Bight
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,23,royalblue+jLB >> $ps << EOF
144.3 -39.6 Bass Straight
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,26,white+jLB >> $ps << EOF
152.1 -38.6 P A C I F I C
152.1 -40.6 O C E A N
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,26,white+jLB >> $ps << EOF
113.8 -12.6 I N D I A N
113.8 -14.6 O C E A N
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,6,royalblue+jLB >> $ps << EOF
137.6 -13.0 Gulf of
136.2 -15.6 Carpentaria
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,6,royalblue+jLB >> $ps << EOF
126.5 -11.8 Timor
126.5 -12.8 Sea
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,23,saddlebrown+jLB >> $ps << EOF
124.2 -31.1 Nullarbor Plain
EOF
# states
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,26,royalblue+jLB >> $ps << EOF
118.8 -26.8 WESTERN
118.8 -28.6 AUSTRALIA
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,26,floralwhite+jLB >> $ps << EOF
130.2 -20.8 NORTHERN
130.2 -22.6 TERRITORY
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,26,royalblue+jLB >> $ps << EOF
140.2 -23.8 QUEENSLAND
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,26,floralwhite+jLB >> $ps << EOF
142.2 -32.0 NEW SOUTH
142.2 -33.6 WALES
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,26,floralwhite+jLB >> $ps << EOF
141.1 -37.0 VICTORIA
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,26,royalblue+jLB >> $ps << EOF
130.8 -28.6 SOUTH
130.8 -29.9 AUSTRALIA
EOF

# Study area
# Rotated rectangle. kwargs: -Sjdirection/width/height, coords
# Scene Center Long DMS: 144°23'46.54"E; Scene Center Lat DMS: 37°28'27.84"S
gmt psxy -R -J -Sj-13/0.8/0.8 -W1.0p,TURQUOISE1 -O -K << EOF >> $ps
144.4 -37.5
EOF
# insert map
# Countries codes: ISO 3166-1 alpha-2. Continent codes AF (Africa), AN (Antarctica), AS (Asia), EU (Europe), OC (Oceania), NA (North America), or SA (South America). -EEU+ggrey -R110/160/-45/-10
gmt psbasemap -R -J -O -K -DjBL+w2.5c+o-0.2c/-0.2c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thin,grey -Rg -JG140/25.0S/$w -Da -Glightgoldenrod1 -A5000 -Bga -Wfaint -EAU+gred -Sdodgerblue -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx6.5/-2.1+o0.1i/0.1i+w2c -O -K >> $ps

# Convert to image file using GhostScript
gmt psconvert Topo_AU.ps -A0.3c -E720 -Tj -Z
