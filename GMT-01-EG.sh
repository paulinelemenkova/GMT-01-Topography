#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: Egypt)
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
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R24/38/21/32 -Geg1_relief.nc
gmt grdcut GEBCO_2019.nc -R24/38/21/32 -Geg_relief.nc
gdalinfo -stats eg1_relief.nc
#  actual_range={-3197,2373}
# Minimum=-3197.000, Maximum=2373.000, Mean=249.820, StdDev=489.362

#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R24/38/21/32 -JM6.5i -Dh -M -EEG > Egypt.txt
#####################################################################

# Make color palette
gmt makecpt -Cwiki-red-sea.cpt -V -T-3197/2373 > pauline.cpt
# elevation geo earth world terra turbo srtm elevation etopo1 globe afrikakarte nordisk-familjebok
# dem1 dem2 dem3 wiki-2.0 GMT_topo.cpt GMT_relief.cpt

ps=Topo_EG.ps
# Make background transparent image

gmt grdimage eg1_relief.nc -Cpauline.cpt -R24/38/21/32 -JM6.5i -I+a15+ne0.75 -t40 -Xc -P -K > $ps

# Add isolines
gmt grdcontour eg1_relief.nc -R -J -C250 -A500+f7p,26,darkbrown -Wthinnest,darkbrown -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps
    
#####################################################################
# CLIPPING
# 1. Start: clip the map by mask to only include country

gmt psclip -R24/38/21/32 -JM6.5i Egypt.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage eg1_relief.nc -Cpauline.cpt -R24/38/21/32 -JM6.5i -I+a15+ne0.75 -t0 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour eg1_relief.nc -R -J -C250 -A500+f7p,26,darkbrown -Wthinnest,darkbrown -O -K >> $ps
# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps
#gmt pscoast -R -J \
    -Ia/thinner,blue -Na -W0.1p -Df -O -K >> $ps

# 3: Undo the clipping
gmt psclip -C -O -K >> $ps
#####################################################################
    
# Add color legend
gmt psscale -Dg24/20.0+w16.0c/0.15i+h+o0.3/0i+ml+e -R -J -Cpauline.cpt \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_TITLE=6p,0,black \
    -Bg500f100a500+l"Colormap: 'wiki-red-sea.cpt' discrete, 20 segments [R=-3197/2373, H, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=WEsN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    --MAP_TITLE_OFFSET=0.7c \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --FONT_LABEL=8p,25,black \
    --FONT_TITLE=13p,0,black \
        -Bpxg4f1a2 -Bpyg4f2a2 -Bsxg2 -Bsyg2 \
    -B+t"Topographic map of Egypt" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=9p,0,black \
    --FONT_ANNOT_PRIMARY=9p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx14.0c/-2.4c+c10+w400k+l"Mercator projection. Scale (km)"+f \
    -UBL/0p/-70p -O -K >> $ps

# Cities -R24/38/21/32
gmt pstext -R -J -N -O -K \
-F+f12p,21,black+jLB -Gwhite@60 >> $ps << EOF
29.00 30.90 Alexandria
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
29.89 31.20 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,21,black+jLB -Gwhite@60 >> $ps << EOF
32.41 31.29 Port Said
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
32.31 31.26 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,21,black+jLB -Gwhite@60 >> $ps << EOF
32.65 30.00 Suez
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
32.55 29.97 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,21,black+jLB -Gwhite@60 >> $ps << EOF
30.48 31.15 Mansoura
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
31.38 31.05 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,21,black+jLB -Gwhite@60 >> $ps << EOF
31.26 30.75 El Mahalla
31.26 30.52 El Kubra
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
31.16 30.97 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,21,black+jLB -Gwhite@60 >> $ps << EOF
29.90 29.40 El Faiyum
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
30.84 29.31 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,21,black+jLB -Gwhite@60 >> $ps << EOF
30.50 30.01 Giza
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
31.21 29.99 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,21,black+jLB -Gwhite@60 >> $ps << EOF
31.27 27.21 Asyut
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
31.17 27.18 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,21,black+jLB -Gwhite@60 >> $ps << EOF
32.55 27.40 Hurghada
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
33.81 27.26 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,21,black+jLB -Gwhite@60 >> $ps << EOF
34.43 27.70 Sharm
34.43 27.43 El Sheikh
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
34.33 27.91 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,21,black+jLB -Gwhite@60 >> $ps << EOF
33.00 24.12 Aswan
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
32.90 24.09 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,21,black+jLB >> $ps << EOF
32.75 25.71 Luxor
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
32.65 25.68 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,21,black+jLB -Gwhite@60 >> $ps << EOF
32.50 26.30 Qena
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
32.72 26.17 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,21,black+jLB -Gwhite@60 >> $ps << EOF
34.10 29.41 Taba
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
34.89 29.49 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,21,black+jLB -Gwhite@60 >> $ps << EOF
33.00 26.85 Safaga
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
33.93 26.73 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,21,black+jLB -Gwhite@60 >> $ps << EOF
32.65 25.33 Esna
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
32.55 25.30 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,21,black+jLB -Gwhite@60 >> $ps << EOF
32.97 25.00 Edfu
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
32.87 24.97 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,21,black+jLB -Gwhite@60 >> $ps << EOF
31.80 26.58 Sohag
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
31.70 26.55 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,21,black+jLB -Gwhite@60 >> $ps << EOF
34.30 23.65 Berenice
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
35.47 23.90 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,21,black+jLB -Gwhite@60 >> $ps << EOF
26.17 31.05 Mersa Matruh
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
27.23 31.35 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,21,black+jLB -Gwhite@60 >> $ps << EOF
31.20 29.10 Beni Suef
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
31.08 29.07 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f14p,22,black+jLB -Gwhite@60 >> $ps << EOF
31.33 30.07 CAIRO
EOF

gmt psxy -R -J -Sa -W0.5p -Gred -O -K << EOF >> $ps
31.23 30.04 0.35c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,21,black+jLB -Gwhite@60 >> $ps << EOF
25.30 28.90 Siwa Oasis
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
25.52 29.21 0.20c
EOF
# GEOGRAPHY
gmt pstext -R -J -N -O -K \
-F+f12p,20,darkbrown+jLB >> $ps << EOF
26.1 28.1 WESTERN
26.1 27.6 DESERT
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,darkbrown+jLB+a-55 -Gwhite@50 >> $ps << EOF
31.9 28.1 Eastern Desert
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,20,darkbrown+jLB+a-45 >> $ps << EOF
24.5 25.8 LIBYAN DESERT
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,6,darkbrown+jLB -Gwhite@50 >> $ps << EOF
33.4 30.02 Sinai
33.1 29.70 Peninsula
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,darkbrown+jLB+a30 >> $ps << EOF
27.00 29.70 Qattara
26.80 29.30 Depression
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,blueviolet+jLB -Glightgoldenrod@50 >> $ps << EOF
32.48 23.70 1st Cataract
EOF
gmt psxy -R -J -S- -W0.8p,deeppink -O -K << EOF >> $ps
32.88 24.08 0.45c
EOF
gmt psxy -R -J -Sx -W0.8p,deeppink -O -K << EOF >> $ps
32.88 24.08 0.45c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,19,gray25+jLB >> $ps << EOF
27.7 21.5 S   U   D   A   N
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,19,gray25+jLB >> $ps << EOF
35.70 30.4 J O R D A N
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,19,gray25+jLB+a-90 >> $ps << EOF
24.5 28.2 L  I  B  Y  A
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,19,gray25+jLB >> $ps << EOF
36.0 28.9 S A U D I
36.0 28.3 A R A B I A
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,19,gray25+jLB+a-70 -Gwhite@60 >> $ps << EOF
34.5 31.2 ISRAEL
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,blue2+jLB -Gwhite@60 >> $ps << EOF
35.40 25.0 Red Sea
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,blue2+jLB -Gwhite@60 >> $ps << EOF
26.10 31.70 M e d i t e r r a n e a n   S e a
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,23,blue2+jLB+a-60 -Gwhite@60 >> $ps << EOF
32.50 29.5 G u l f  o f  S u e z
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,darkbrown+jLB+a-60 >> $ps << EOF
29.0 28.5 Ghurd Abu Muharrik Dunes
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,darkbrown+jLB >> $ps << EOF
25.6 23.4 Gilf al-Kebir Plateau
EOF
# insert map
# Countries codes: ISO 3166-1 alpha-2. Continent codes AF (Africa), AN (Antarctica), AS (Asia), EU (Europe), OC (Oceania), NA (North America), or SA (South America). -EEU+ggrey
gmt psbasemap -R -J -O -K -DjBR+w3.0c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thin,grey -Rg -JG28.0/25.0N/$w -Da -Glightgoldenrod1 -A5000 -Bga -Wfaint -EEG+gred -Sdodgerblue -O -K -X$x0 -Y$y0 >> $ps
#gmt pscoast -Rg -JG12/5N/$w -Da -Gbrown -A5000 -Bg -Wfaint -ECM+gbisque -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx6.5/-3.1+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y8.2c -N -O \
    -F+f10p,0,black+jLB >> $ps << EOF
3.0 10.4 Digital elevation data: SRTM/GEBCO, 15 arc sec resolution grid
EOF

# Convert to image file using GhostScript
gmt psconvert Topo_EG.ps -A0.5c -E720 -Tj -Z
