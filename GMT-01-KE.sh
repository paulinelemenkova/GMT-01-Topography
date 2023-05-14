#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: Kenya)
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert
# http://soliton.vm.bytemark.co.uk/pub/cpt-city/njgs/index.html

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
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R31.5/42.5/-5/5 -Gke_relief.nc
gmt grdcut GEBCO_2019.nc -R31.5/42.5/-5/5 -Gke_relief1.nc
gdalinfo -stats ke_relief.nc
# Minimum=-2217.000, Maximum=5677.000, Mean=849.149, StdDev=702.927

#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R31.5/42.5/-5/5 -JU37/6.5i -Dh -M -EKE > Kenya.txt
#####################################################################

# Make color palette
#gmt makecpt -Cafrikakarte-topo -V -T443/5110 > pauline.cpt
#gmt makecpt -Ceurope_3 -V -T-2217/5677 > pauline.cpt
#gmt makecpt -Cwiki-schwarzwald-d010 -V -T-2217/5677 > pauline.cpt
gmt makecpt -Cgeo -V -T-2217/5677 > pauline.cpt
#gmt makecpt -Cwiki-1.02 -V -T443/5110 > pauline.cpt
# elevation etopo1 world elevation dem1 dem2 dem3 globe geo srtm turbo terra earth relief costa-rica

ps=Topo_KE.ps
# Make background transparent image
#gmt grdimage ke_relief.nc -Cpauline.cpt -R31.5/42.5/-5/5 -JU37/6.5i -I+a15+ne0.75 -t50 -Xc -P -K > $ps
gmt grdimage ke_relief.nc -Cpauline.cpt -R31.5/42.5/-5/5 -JU37/6.5i -I+a15+ne0.75 -t50 -Xc -P -K > $ps

# Add isolines
gmt grdcontour ke_relief1.nc -R -J -C1000 -A1000+f7p,26,darkbrown -Wthinner,darkbrown -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,red -W0.1p -Df -O -K >> $ps
gmt pscoast -R -J -Ia/thinner,blue -Na -Sroyalblue1 -W2/thin,blue,0.1p -Df -O -K >> $ps
    
#####################################################################
# CLIPPING
# 1. Start: clip the map by mask to only include country
gmt psclip -R31.5/42.5/-5/5 -JU37/6.5i Kenya.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage ke_relief.nc -Cpauline.cpt -R31.5/42.5/-5/5 -JU37/6.5i -I+a15+ne0.75 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour ke_relief1.nc -R -J -C250 -Wthinnest,darkbrown -O -K >> $ps
# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps
gmt pscoast -R -J -Ia/thinner,blue -Na -Sroyalblue1 -W2/thin,blue,0.1p -Df -O -K >> $ps

# 3: Undo the clipping
gmt psclip -C -O -K >> $ps
#####################################################################
    
# Add color legend
gmt psscale -Dg31.0/-5.7+w16.0c/0.15i+h+o0.3/0i+ml+e -R -J -Cpauline.cpt \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_TITLE=6p,0,black \
    -Bg500f50a500+l"Colormap: 'geo' [R=-2217/5677, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=WEsN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    -Bpxg2f0.5a1 -Bpyg2f0.5a1 -Bsxg1 -Bsyg1 \
    --MAP_TITLE_OFFSET=0.8c \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --FONT_LABEL=8p,25,black \
    --FONT_TITLE=14p,25,black \
    -B+t"Topographic map of Kenya" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx14.5c/-2.5c+c10+w300k+l"UTM projection, Zone 37. Scale (km)"+f \
    -UBL/0p/-70p -O -K >> $ps

# Texts
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,19,black+jLB -Gwhite@70 >> $ps << EOF
32.2 4.7 S O U T H
32.2 4.3 S U D A N
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,19,black+jLB -Gwhite@80 >> $ps << EOF
38.1 4.2 E T H I O P I A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,19,black+jLB+a90 >> $ps << EOF
41.8 -0.5 S O M A L I A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,19,black+jLB >> $ps << EOF
32.5 -3.5 T A N Z A N I A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,19,black+jLB >> $ps << EOF
32.4 2.2 U G A N D A
EOF
#
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,26,white+jLB >> $ps << EOF
32.5 -0.9 Lake
32.5 -1.3 Victoria
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,26,white+jLB+a-90 >> $ps << EOF
36.0 4.2 Lake
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,26,white+jLB+a-55 >> $ps << EOF
35.98 3.5 Turkana
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,26,white+jLB >> $ps << EOF
41.2 -2.4 INDIAN
41.2 -2.7 OCEAN
EOF
#
# Cities
gmt pstext -R -J -N -O -K \
-F+f12p,21,white+jLB >> $ps << EOF
37.98 2.47 Marsabit
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
37.98 2.33 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,21,white+jLB >> $ps << EOF
39.06 3.23 Moyale
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
39.06 3.53 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,21,white+jLB >> $ps << EOF
40.10 1.85 Wajir
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
40.05 1.75 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,21,white+jLB >> $ps << EOF
40.20 2.95 El Wak
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
40.93 2.80 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,21,white+jLB >> $ps << EOF
40.60 -2.10 Lamu
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
40.90 -2.27 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,21,white+jLB >> $ps << EOF
40.13 -3.10 Malindi
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
40.13 -3.22 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,21,white+jLB >> $ps << EOF
39.36 -3.95 Mombasa
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
39.66 -4.05 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,21,white+jLB >> $ps << EOF
36.00 -0.20 Nakuru
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
36.06 -0.30 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,21,white+jLB >> $ps << EOF
35.18 0.65 Eldoret
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
35.28 0.52 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,21,white+jLB >> $ps << EOF
34.76 0.05 Kisumu
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
34.76 -0.08 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,21,white+jLB >> $ps << EOF
36.00 -1.15 Kikuyu
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
36.64 -1.25 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,21,white+jLB >> $ps << EOF
37.08 -1.00 Thika
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
37.08 -1.05 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,21,white+jLB >> $ps << EOF
35.43 -0.61 Naivasha
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
36.43 -0.71 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,21,white+jLB >> $ps << EOF
36.96 -1.80 Ruiru
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
36.96 -1.48 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,21,white+jLB >> $ps << EOF
36.55 -0.63 Karuri
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
37.05 -0.73 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f15p,22,white+jLB >> $ps << EOF
37.00 -1.40 NAIROBI
EOF
gmt psxy -R -J -Sa -W0.5p,white -Gred -O -K << EOF >> $ps
36.83 -1.28 0.40c
EOF
# rivers & lakes
gmt pstext -R -J -N -O -K \
-F+f12p,23,blue1+jLB+a95 >> $ps << EOF
35.40 2.15 Turkwel
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,lightcyan+jLB+a-10 >> $ps << EOF
40.30 1.50 Bor
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,lightcyan+jLB+a29 >> $ps << EOF
40.50 0.29 Dera
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,lightcyan+jLB+a-75 >> $ps << EOF
40.15 -1.50 Tana
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,lightcyan+jLB+a-7 >> $ps << EOF
39.25 -2.98 Galana
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,blue1+jLB+a-60 >> $ps << EOF
38.40 -2.50 Athi
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,lightcyan+jLB+a40 >> $ps << EOF
35.05 -1.10 Mara
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,lightcyan+jLB >> $ps << EOF
36.40 -2.00 Lake
36.40 -2.25 Magali
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,lightcyan+jLB >> $ps << EOF
36.15 0.80 Lake
36.15 0.55 Baringo
EOF
#
gmt pstext -R -J -N -O -K \
-F+f12p,23,lemonchiffon1+jLB >> $ps << EOF
37.35 0.15 Mount
37.35 -0.05 Kenya
EOF
gmt psxy -R -J -St -W0.5p -Gmagenta -O -K << EOF >> $ps
37.31 -0.15 0.30c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,lemonchiffon1+jLB -Gsaddlebrown@70 >> $ps << EOF
37.30 -2.65 Mount
37.30 -2.90 Kilimanjaro
EOF
gmt psxy -R -J -St -W0.5p -Gmagenta -O -K << EOF >> $ps
37.35 -3.07 0.30c
EOF
# Study area
# Rotated rectangle. kwargs: coords, direction degrees, x and y-dimension
gmt psxy -R -J -Sj1c -W1.5p,red -O -K << EOF >> $ps
39.23 1.44 -15 2.0 2.0
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,21,lightyellow1+jLB >> $ps << EOF
39.03 1.44 Study
39.03 1.20 Area
EOF
#
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,23,cornsilk1+jLB+a0 >> $ps << EOF
38.74 -0.30 Kora
38.74 -0.55 National
38.74 -0.80 Park
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,23,cornsilk1+jLB+a0 >> $ps << EOF
38.70 -3.00 Tsavo
38.70 -3.20 National
38.70 -3.40 Park
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,23,cornsilk1+jLB+a0 >> $ps << EOF
35.23 -1.30 Masai Mara
35.23 -1.50 National
35.23 -1.70 Reserve
EOF

gmt pstext -R -J -N -O -K \
-F+jTL+f10p,23,cornsilk1+jLB -Gsaddlebrown@70 >> $ps << EOF
38.00 -3.30 Taita
38.00 -3.50 Hills
EOF
gmt psxy -R -J -Ss -W0.5p -Ggold -O -K << EOF >> $ps
35.14 -1.49 0.30c
EOF
# insert map
# Countries codes: ISO 3166-1 alpha-2. Continent codes AF (Africa), AN (Antarctica), AS (Asia), EU (Europe), OC (Oceania), NA (North America), or SA (South America). -EEU+ggrey
gmt psbasemap -R -J -O -K -DjBR+w3.2c+o-0.2c/-0.2c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thinnest,grey --MAP_FRAME_PEN=thin,white -Rg -JG28.0/-2.0S/$w -Da -Glightgoldenrod1 -A5000 -Bga -Wfaint -EUG+gred -Sdodgerblue -O -K -X$x0 -Y$y0 >> $ps
#gmt pscoast -Rg -JG12/5N/$w -Da -Gbrown -A5000 -Bg -Wfaint -ECM+gbisque -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx7.0/-2.9+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y10.0c -N -O \
    -F+f10p,0,black+jLB >> $ps << EOF
2.0 9.0 Digital elevation data: GEBCO/SRTM, 15 arc sec (ca. 450 m) resolution grid
EOF

# Convert to image file using GhostScript
gmt psconvert Topo_KE.ps -A0.5c -E720 -Tj -Z
