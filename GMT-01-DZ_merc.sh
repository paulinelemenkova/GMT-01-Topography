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
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R-10/13/18/38 -Gdz1_relief.nc
gmt grdcut GEBCO_2019.nc -R-10/13/18/38 -Gdz_relief.nc
gdalinfo -stats dz1_relief.nc
# Minimum=-4918.000, Maximum=3785.000, Mean=332.901, StdDev=802.901

# Make color palette
# gmt makecpt -Cgeo -V -T-4918/3785 > pauline.cpt
gmt makecpt -Cturbo -V -T-4918/3785 > pauline.cpt
# elevation etopo1 world elevation dem1 dem2 dem3 globe geo srtm turbo terra earth

#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R-10/13/18/38 -JM6.5i -Dh -M -EDZ > DZ.txt
#####################################################################

ps=Topo_DZ.ps
# Make background transparent image

gmt grdimage dz_relief.nc -Cpauline.cpt -R-10/13/18/38 -JM6.5i -I+a15+ne0.75 -t40 -Xc -P -K > $ps

# Add isolines
gmt grdcontour dz1_relief.nc -R -J -C500 -A500+f7p,26,darkbrown -Wthinnest,darkbrown -O -K >> $ps

# Add coastlines, borders, rivers, lakes
gmt pscoast -R -J -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps
    
#####################################################################
# CLIPPING
# 1. Start: clip the map by mask to only include country

gmt psclip -R-10/13/18/38 -JM6.5i DZ.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage dz_relief.nc -Cpauline.cpt -R-10/13/18/38 -JM6.5i -I+a15+ne0.75 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour dz1_relief.nc -R -J -C500 -A500+f7p,26,darkbrown -Wthinnest,darkbrown -O -K >> $ps
# Add coastlines, borders, rivers, lakes
gmt pscoast -R -J -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps

# 3: Undo the clipping
gmt psclip -C -O -K >> $ps
#####################################################################
    
# Add color legend -R-10/13/18/38
gmt psscale -Dg-10/16.5+w16.0c/0.15i+h+o0.3/0i+ml+e -R -J -Cpauline.cpt \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --FONT_TITLE=8p,0,black \
    -Bg500f50a500+l"Colormap: 'turbo' Google's Improved Rainbow Colormap for Visualization [R=-4373/3703, H, C=RGB]" \
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
    -B+t"Topographic map of Algeria" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=9p,0,black \
    --FONT_ANNOT_PRIMARY=9p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx14.5c/-2.4c+c10+w500k+l"Mercator projection. Scale (km)"+f \
    -UBL/0p/-70p -O -K >> $ps

# Texts
# cities
gmt pstext -R -J -N -O -K \
-F+f12p,21,black+jLB -Glightcyan2@50 >> $ps << EOF
-1.90 35.59 Oran
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-0.63 35.69 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,21,black+jLB -Gwheat2@60 >> $ps << EOF
5.60 36.50 Constantine
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
6.60 36.35 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,21,black+jLB -Glemonchiffon2@60 >> $ps << EOF
1.60 36.47 Blida
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
2.83 36.47 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,21,black+jLB -Glightbrown@70 >> $ps << EOF
5.51 35.80 Sétif
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
5.41 36.19 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,21,black+jLB -Gdarkgoldenrod2@70 >> $ps << EOF
2.20 34.82 Djelfa
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
3.25 34.67 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,21,black+jLB -Gdarkolivegreen1@70 >> $ps << EOF
7.77 37.00 Annaba
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
7.77 36.90 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,21,black+jLB -Gdarkolivegreen1@70 >> $ps << EOF
6.10 32.80  El Oued
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
7.18 33.45 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,21,black+jLB -Glightbrown@70 >> $ps << EOF
1.35 35.36  Tiaret
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
1.31 35.36 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,21,black+jLB -Glightbrown@70 >> $ps << EOF
-2.42 31.15  Béchar
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-2.22 31.01 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,21,black+jLB -Gdarkolivegreen1@70 >> $ps << EOF
5.06 36.90  Béjaïa
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
5.06 36.75 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,21,black+jLB >> $ps << EOF
5.42 32.10 Ouargla
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
5.32 31.95 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,21,black+jLB >> $ps << EOF
-2.50 36.03 Mostaganem
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
0.08 35.93 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,21,black+jLB >> $ps << EOF
6.6 35.60 Tébessa
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
8.12 35.40 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,22,black+jLB -Gpalegoldenrod@70 >> $ps << EOF
2.16 36.95 ALGIERS
EOF
gmt psxy -R -J -Ss -W0.5p -Gred -O -K << EOF >> $ps
3.06 36.75 0.35c
EOF
# countries -R-10/13/18/38
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,19,black+jLB -Gwhite@60 >> $ps << EOF
-9.3 30.5 M O R O C C O
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,19,black+jLB+a90 >> $ps << EOF
-8.2 19.0 M A U R I T A N I A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f13p,19,black+jLB >> $ps << EOF
-4.6 21.0 M  A  L  I
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,19,black+jLB -Gwhite@80 >> $ps << EOF
5.0 18.7 N I G E R
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,19,black+jLB -Gwhite@80 >> $ps << EOF
10.1 25.8 L Y B I A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,19,black+jLB -Gwhite@90 >> $ps << EOF
8.3 33.0 TUNISIA
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,19,black+jLB -Gwhite@80 >> $ps << EOF
-9.8 27.0 WESTERN
-9.8 26.5 SAHARA
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,19,black+jLB -Gwhite@60 >> $ps << EOF
-6.2 37.3 S P A I N
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f18p,19,black+jLB -Gwhite@90 >> $ps << EOF
-5.9 27.2 A      L      G      E      R      I      A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,23,navajowhite4+jLB -Gwhite@90 >> $ps << EOF
1.0 31.0 A L - M A G H R I B
EOF
# GEOGRAPHY
gmt pstext -R -J -N -O -K \
-F+f12p,23,darkred+jLB+a30 -Gwhite@70 >> $ps << EOF
-7.2 31.00 A T L A S  M O U N T A I N S
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,lightyellow+jLB+a30 -Gdarkgoldenrod2@60 >> $ps << EOF
-1.30 33.40 High Plateau
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,ivory1+jLB+a30 -Ggoldenrod2@60 >> $ps << EOF
-1.60 34.50 Trara Mts
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,ivory1+jLB+a30 -Ggoldenrod1@60 >> $ps << EOF
-1.30 34.1 Tlemcen
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,ivory1+jLB+a30 -Ggreenyellow@80 >> $ps << EOF
0.30 35.9 Dahra
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,darkred+jLB+a10 -Glightbrown@70 >> $ps << EOF
1.50 35.7 T E L L  A T L A S
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,23,darkred+jLB+a30 >> $ps << EOF
4.50 30.3 Grand Erg Oriental
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,23,darkred+jLB+a30 >> $ps << EOF
-1.70 30.3 Grand Erg Occidental
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,23,ivory1+jLB+a30 -Ggoldenrod1@60 >> $ps << EOF
-1.00 32.3 Saharan Atlas
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,ivory1+jLB+a30 -Ggoldenrod1@60 >> $ps << EOF
0.29 32.52 Kçour
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,ivory1+jLB+a30 -Ggoldenrod1@60 >> $ps << EOF
1.8 33.9 Amour
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,ivory1+jLB -Ggoldenrod1@60 >> $ps << EOF
3.5 34.80 Ouled
3.6 34.30 Naïl
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,darkred+jLB >> $ps << EOF
5.80 29.4 Erg
5.00 29.0 Issaouane
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,lightyellow+jLB >> $ps << EOF
5.80 23.25 HOGGAR
5.80 22.70 MOUNTAINS
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,darkbrown+jLB >> $ps << EOF
2.50 20.90 Adrar
2.10 20.45 des Ifoghas
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,23,darkred+jLB -Gnavajowhite3@70 >> $ps << EOF
2.10 28.70 Tademaït
2.10 28.20 Plateau
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,darkred+jLB >> $ps << EOF
-5.00 26.60 El Eglab
-5.00 26.10 Massif
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,deepskyblue4+jLB+a-65 >> $ps << EOF
-0.80 27.90 Touat Oases
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,darkbrown+jLB+a30 >> $ps << EOF
-3.00 24.55 Erg Chech
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,darkbrown+jLB+a30 >> $ps << EOF
-5.50 27.80 Erg Iguidi
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,steelblue4+jLB >> $ps << EOF
1.00 26.20 Sebkha
1.00 25.75 Azzel Matti
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,23,lightyellow+jLB+a-35 -Gnavajowhite3@70 >> $ps << EOF
7.00 26.10 Tassili-n-Ajjer Plateau
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f17p,2,navajowhite4+jLB -Gwhite@90 >> $ps << EOF
-3.0 24.1 S    A    H    A    R    A
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,oldlace+jLB >> $ps << EOF
4.30 23.60 Tahat
4.50 23.20 Mt.
EOF
gmt psxy -R -J -St -W0.5p,white -Gred -O -K << EOF >> $ps
5.53 23.29 0.35c
EOF
# water
gmt pstext -R -J -N -O -K \
-F+f11p,23,blue1+jLB -Gwhite@80 >> $ps << EOF
5.80 34.50 Chotts
5.50 34.10 Melrhir &
5.25 33.70 Merouane
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,23,blue1+jLB -Gwhite@80 >> $ps << EOF
4.10 35.60 Chott
3.70 35.20 el Hodna
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,23,blue1+jLB -Gwhite@80 >> $ps << EOF
1.50 37.50 M e d i t e r r a n e a n   S e a
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,23,white+jLB >> $ps << EOF
-9.90 34.70 Atlantic
-9.90 34.20 Ocean
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,23,blue1+jLB+a-45 >> $ps << EOF
-2.10 30.1 Wadi Saoura
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,navajowhite4+jLB -Ggreenyellow@80 >> $ps << EOF
3.80 32.30 M'ZAB
EOF
# Study area
# Rotated rectangle. kwargs: coords, direction degrees, x and y-dimension
gmt psxy -R -J -Sj1c -W1.5p,red -O -K << EOF >> $ps
6.33 34.33 -15 1.7 1.7
EOF
# insert map
gmt psbasemap -R -J -O -K -DjBR+w3.2c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thin,grey -Rg -JG0/8N/$w -Da -Glightgoldenrod1 -A5000 -Bga -Wfaint -EDZ+gred -Sroyalblue2 -O -K -X$x0 -Y$y0 >> $ps
#gmt pscoast -Rg -JG12/5N/$w -Da -Gbrown -A5000 -Bg -Wfaint -ECM+gbisque -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx7.0/-3.0+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y10.2c -N -O \
    -F+f10p,0,black+jLB >> $ps << EOF
3.0 10.4 Digital elevation data: SRTM/GEBCO, 15 arc sec resolution grid
EOF

# Convert to image file using GhostScript
gmt psconvert Topo_DZ.ps -A0.5c -E720 -Tj -Z
