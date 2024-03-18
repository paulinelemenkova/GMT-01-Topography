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
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R35.5/44.5/12/18 -Ger1_relief.nc
gmt grdcut GEBCO_2023.nc -R35.5/44.5/12/18 -Ger_relief.nc
gmt grdinfo -M er_relief.nc
# -1997/4461

# Make color palette
#gmt makecpt -Cterra -V -T-1000/1500 > pauline.cpt
#gmt makecpt -Cetopo1 -V -T-1664/1906 > pauline.cpt
gmt makecpt -Cgeo -V -T-1997/4461 > pauline.cpt
# elevation etopo1 world elevation dem1 dem2 dem3 globe geo srtm turbo terra earth

#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R35.5/44.5/12/18 -JM6.5i -Dh -M -EER > ER.txt
#####################################################################

ps=Topo_ER.ps
# Make background transparent image

gmt grdimage er_relief.nc -Cpauline.cpt -R35.5/44.5/12/18 -JM6.5i -I+a15+ne0.75 -t40 -Xc -P -K > $ps

# Add isolines
gmt grdcontour er1_relief.nc -R -J -C500 -Wthinnest,darkbrown -O -K >> $ps

# Add coastlines, borders, rivers, lakes
gmt pscoast -R -J -Ia/thinnest,blue -Na -N1/thickest,tomato -W0.1p -Df -O -K >> $ps

#####################################################################
# CLIPPING
# 1. Start: clip the map by mask to only include country

gmt psclip -R35.5/44.5/12/18 -JM6.5i ER.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage er_relief.nc -Cpauline.cpt -R35.5/44.5/12/18 -JM6.5i -I+a15+ne0.75 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour er1_relief.nc -R -J -C500 -Wthinnest,darkbrown -O -K >> $ps
# Add coastlines, borders, rivers, lakes
gmt pscoast -R -J -Ia/thinnest,blue -Na -N1/thickest,tomato -W0.1p -Df -O -K >> $ps
# Add lakes
#gmt pscoast -R -J -Ia/thinner,blue -Na -Sroyalblue1 -W2/thin,blue,0.1p -Df -O -K >> $ps

# 3: Undo the clipping
gmt psclip -C -O -K >> $ps
#####################################################################
    
# Add color legend -R35.5/44.5/12/18
gmt psscale -Dg34.3/12.0+w11.0c/0.15i+v+o0.3/0i+ml+e -R -J -Cpauline.cpt \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --FONT_TITLE=8p,0,black \
    -Bg500f50a500+l"Colormap: 'geo' colormap for topography [R=-1997/4461, H, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=wESN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    --MAP_TICK_PEN_PRIMARY=thinner,dimgray \
    --MAP_FRAME_WIDTH=0.1c \
    --MAP_TITLE_OFFSET=0.7c \
    --FONT_ANNOT_PRIMARY=10p,0,black \
    --FONT_LABEL=12p,25,black \
    --FONT_TITLE=14p,0,black \
    -Bpxf2a1g1 -Bpyf2a1g1 -Bsxg1 -Bsyg1 \
    -B+t"Topographic map of Eritrea" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=11p,0,black \
    --FONT_ANNOT_PRIMARY=11p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx14.5c/-1.5c+c10+w300k+l"Mercator Projection. Scale (km)"+f \
    -UBL/0p/-40p -O -K >> $ps

# Texts
gmt pstext -R -J -N -O -K \
-F+jTL+f15p,2,blue+jLB >> $ps << EOF
40.3 17.10 R E D  S E A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,26,blue+jLB+a-54 -GLIGHTSKYBLUE1@60 >> $ps << EOF
42.70 13.5 Bab-el-Mandeb
EOF
# countries
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,19,darkslategray+jLB >> $ps << EOF
42.25 12.05 DJIBOUTI
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f13p,19,darkslategray+jLB >> $ps << EOF
35.6 16.50 S U D A N
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f13p,19,darkslategray+jLB >> $ps << EOF
37.8 13.50 E T H I O P I A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f13p,19,darkslategray+jLB -Gwhite@70 >> $ps << EOF
43.40 15.60 YEMEN
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f13p,19,darkslategray+jLB -Gwhite@70 >> $ps << EOF
42.55 17.7 SAUDI ARABIA
EOF
#
# cities -R35.5/44.5/12/18
gmt pstext -R -J -N -O -K \
-F+f11p,0,mintcream+jLB -Gsaddlebrown@70 >> $ps << EOF
37.75 15.83 Keren
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
38.45 15.77 0.25c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,0,mintcream+jLB -Gsaddlebrown@80 >> $ps << EOF
39.13 15.10 Dekemhare
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
39.03 15.06 0.25c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,0,mintcream+jLB -Gsaddlebrown@80 >> $ps << EOF
38.40 15.51 Massawa
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
39.45 15.61 0.25c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,0,mintcream+jLB -Gsaddlebrown@70 >> $ps << EOF
37.60 14.89 Mendefera
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
38.81 14.89 0.25c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,0,mintcream+jLB >> $ps << EOF
42.55 12.90 Assab
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
42.74 13.01 0.25c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,0,mintcream+jLB >> $ps << EOF
36.9 15.22 Barentu
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
37.6 15.12 0.25c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,0,mintcream+jLB -Gsaddlebrown@70 >> $ps << EOF
39.47 14.63 Adi Keyh
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
39.37 14.83 0.25c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,0,mintcream+jLB >> $ps << EOF
41.70 13.55 Edd
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
41.70 13.83 0.25c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,0,mintcream+jLB >> $ps << EOF
37.00 15.55 Agordat
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
37.88 15.55 0.25c
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,0,black+jLB -Gwhite@60 >> $ps << EOF
39.0 15.30 Asmara
EOF
gmt psxy -R -J -Ss -W0.5p -Gred -O -K << EOF >> $ps
38.92 15.32 0.30c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,0,mintcream+jLB -Gsaddlebrown@70 >> $ps << EOF
37.80 16.60 Nakfa
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
38.47 16.66 0.25c
EOF
# geography
gmt pstext -R -J -N -O -K \
-F+f12p,2,darkgreen+jLB >> $ps << EOF
40.40 15.80 Dahlak
40.42 15.60 Archipelago
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,2,cornsilk+jLB+a-45 >> $ps << EOF
40.85 14.20 D a n a k i l      A l p s
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,2,navy+jLB+a-45 >> $ps << EOF
40.20 14.10 Danakil Depresion
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,2,cornsilk+jLB >> $ps << EOF
40.80 12.40 Afar
40.40 12.10 Depresion
EOF
# Study area
#Scene Center Lat DMS     15°54'04.03"N
#Scene Center Long DMS     39°17'37.82"E
# Rotated rectangle. kwargs: -Sjdirection/width/height, coords
gmt psxy -R -J -Sj-13/3.2/3.2 -W1.5p,blue1 -O -K << EOF >> $ps
39.29 15.90
EOF
#
gmt pstext -R -J -N -O -K -F+f12p,2,navy+jLB -Gwhite@80>> $ps << EOF
38.8 15.80 Study Area
EOF

# Texts
# insert map -R35.5/44.5/12/18
gmt psbasemap -R -J -O -K -DjBL+w3.2c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thin,grey --MAP_FRAME_PEN=thin,azure -Rg -JG40/16N/$w -Da -Glightgoldenrod1 -A5000 -Bga -Wfaint -EER+gred -Sroyalblue3 -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx7.0/-2.1+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y5.2c -N -O \
    -F+f12p,0,black+jLB >> $ps << EOF
2.5 10.4 Digital elevation data: GEBCO, 15 arc sec resolution grid
EOF

# Convert to image file using GhostScript
gmt psconvert Topo_ER.ps -A0.5c -E720 -Tj -Z
