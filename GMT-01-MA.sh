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
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R-15/0/27/37 -Gma1_relief.nc
gmt grdcut GEBCO_2023.nc -R-15/0/27/37 -Gma_relief.nc
gmt grdinfo -M ma_relief.nc
# Minimum=-5141.000, Maximum=4038.000, Mean=332.901, StdDev=802.901

# Make color palette
gmt makecpt -Cgeo -V -T-5141/4038 > pauline.cpt
#gmt makecpt -Cturbo -V -T-5141/4038 > pauline.cpt
# elevation etopo1 world elevation dem1 dem2 dem3 globe geo srtm turbo terra earth

#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R-15/0/27/37 -JM6.5i -Dh -M -EMA > MA.txt
#####################################################################

ps=Topo_MA.ps
# Make background transparent image

gmt grdimage ma_relief.nc -Cpauline.cpt -R-15/0/27/37 -JM6.5i -I+a15+ne0.75 -t40 -Xc -P -K > $ps

# Add isolines
gmt grdcontour ma1_relief.nc -R -J -C500 -A500+f7p,26,darkbrown -Wthinnest,darkbrown -O -K >> $ps

# Add coastlines, borders, rivers, lakes
gmt pscoast -R -J -Ia/thinner,blue -Na -N1/thickest,tomato -W0.1p -Df -O -K >> $ps
    
#####################################################################
# CLIPPING
# 1. Start: clip the map by mask to only include country

gmt psclip -R-15/0/27/37 -JM6.5i MA.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage ma_relief.nc -Cpauline.cpt -R-15/0/27/37 -JM6.5i -I+a15+ne0.75 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour ma1_relief.nc -R -J -C500 -A500+f7p,26,darkbrown -Wthinnest,darkbrown -O -K >> $ps
# Add coastlines, borders, rivers, lakes
gmt pscoast -R -J -Ia/thinner,blue -Na -N1/thickest,tomato -W0.1p -Df -O -K >> $ps

# 3: Undo the clipping
gmt psclip -C -O -K >> $ps
#####################################################################
    
# Add color legend -R-15/0/27/37
gmt psscale -Dg-15/26+w16.0c/0.15i+h+o0.3/0i+ml+e -R -J -Cpauline.cpt \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --FONT_TITLE=8p,0,black \
    -Bg500f50a500+l"Colormap: 'geo' Colors for global bathymetry/topography relief [R=-4373/3703, H, C=RGB]" \
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
    -Bpxf1a2g4 -Bpyg4f2a2 -Bsxg2 -Bsyg2 \
    -B+t"Carte topographique du Maroc" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=9p,0,black \
    --FONT_ANNOT_PRIMARY=9p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx14.5c/-2.5c+c10+w500k+l"Projection de Mercator. échelle (km)"+f \
    -UBL/0p/-70p -O -K >> $ps

# Study area
# Rotated rectangle. kwargs: -Sjdirection/width/height, coords
# LAT: 34°36'38.05"N LON: 5°32'33.07"W
gmt psxy -R -J -Sj-13/2.0/2.0 -W2.0p,deeppink -O -K << EOF >> $ps
-5.54 34.75
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,21,gold+jLB >> $ps << EOF
-6.10 34.70 Zone
-6.20 34.40 d'étude
EOF

# Texts
# Cities -R-15/0/27/37
gmt pstext -R -J -N -O -K \
-F+f11p,0,ivory+jLB >> $ps << EOF
-7.48 33.50 Casablanca
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-7.58 33.53 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,0,ivory+jLB >> $ps << EOF
-5.20 33.75 Fez
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-5.00 34.04 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,0,ivory+jLB >> $ps << EOF
-9.70 30.53 Agadir
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-9.60 30.43 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,0,ivory+jLB >> $ps << EOF
-7.02 31.02 Ouarzazate
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-6.92 30.92 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,0,ivory+jLB >> $ps << EOF
-10.16 29.08 Guelmim
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-10.06 28.98 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,0,ivory+jLB >> $ps << EOF
-8.11 31.76 Marrakesh
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-8.01 31.63 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,1,white+jLB >> $ps << EOF
-6.64 34.03 Rabat
EOF
gmt psxy -R -J -Ss -W0.5p -Gred -O -K << EOF >> $ps
-6.84 34.02 0.35c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,0,ivory+jLB >> $ps << EOF
-7.00 32.43 Beni Mellal
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-6.36 32.33 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,0,ivory+jLB >> $ps << EOF
-4.52 32.03 Errachidia
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-4.42 31.93 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,0,black+jLB -Gwhite@60 >> $ps << EOF
-5.85 35.45 Tangier
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-5.80 35.77 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,0,ivory+jLB >> $ps << EOF
-2.8 34.40 Oujda
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-1.91 34.68 0.20c
EOF
# geography
gmt pstext -R -J -N -O -K \
-F+f12p,2,lemonchiffon+jLB+a-40 >> $ps << EOF
-5.50 35.30 Rif Mts.
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,2,lemonchiffon+jLB+a32 >> $ps << EOF
-6.50 31.40 A   T   L   A   S
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,2,lemonchiffon+jLB+a35 >> $ps << EOF
-9.00 29.40 Anti Atlas
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,23,blue+jLB >> $ps << EOF
-7.40 36.1 Détroit de
-7.40 35.8 Gibraltar
EOF
gmt pstext -R -J -N -O -K \
-F+f14p,23,white+jLB >> $ps << EOF
-11.80 34.6 O C É A N
-12.30 34.1 A T L A N T I Q U E
EOF
gmt pstext -R -J -N -O -K \
-F+f14p,23,white+jLB >> $ps << EOF
-3.3 36.3 Mer Méditerranée
EOF

# countries
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,0,navajowhite4+jLB >> $ps << EOF
-13.0 27.15 SAHARA OCCIDENTAL
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,0,navajowhite4+jLB >> $ps << EOF
-5.0 28.35 A  L  G  É  R  I  E
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,0,ivory+jLB >> $ps << EOF
-5.8 36.7 ESPAGNE
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,2,lemonchiffon+jLB+a45 >> $ps << EOF
-14.60 29.10 Les îles Canaries
-14.50 28.70 (Espagne)
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,2,lemonchiffon+jLB >> $ps << EOF
-14.80 33.40 Îles de Madère
-14.80 33.10 (Portugal)
EOF

# insert map
gmt psbasemap -R -J -O -K -DjTL+w3.2c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thin,grey --MAP_FRAME_PEN=thin,azure -Rg -JG-7/31N/$w -Da -Glightgoldenrod1 -A5000 -Bga -Wfaint -EMA+gred -Sroyalblue3 -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx7.0/-3.1+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y6.8c -N -O \
    -F+f10p,0,black+jLB >> $ps << EOF
0.5 10.4 Données numériques d'élévation : SRTM/GEBCO, grille de résolution de 15 secondes d'arc
EOF

# Convert to image file using GhostScript
gmt psconvert Topo_MA.ps -A0.5c -E720 -Tj -Z
