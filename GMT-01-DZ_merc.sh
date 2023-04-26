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
gmt makecpt -Cgeo -V -T-4918/3785 > pauline.cpt
# elevation etopo1 world elevation dem1 dem2 dem3 globe geo srtm turbo terra earth

#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R-10/13/18/38 -JM6.5i -Dh -M -EDZ > DZ.txt
#####################################################################

ps=Topo_DZ.ps
# Make background transparent image

gmt grdimage dz1_relief.nc -Cpauline.cpt -R-10/13/18/38 -JM6.5i -I+a15+ne0.75 -t40 -Xc -P -K > $ps

# Add isolines
gmt grdcontour dz1_relief.nc -R -J -C250 -A500+f7p,26,darkbrown -Wthinnest,darkbrown -O -K >> $ps

# Add coastlines, borders, rivers, lakes
gmt pscoast -R -J -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps
    
#####################################################################
# CLIPPING
# 1. Start: clip the map by mask to only include country

gmt psclip -R-10/13/18/38 -JM6.5i DZ.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage dz1_relief.nc -Cpauline.cpt -R-10/13/18/38 -JM6.5i -I+a15+ne0.75 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour dz1_relief.nc -R -J -C250 -A500+f7p,26,darkbrown -Wthinnest,darkbrown -O -K >> $ps
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
    -Bg500f50a500+l"Colormap: 'geo' Colors for global topography relief [R=-4373/3703, H, C=RGB]" \
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
# countries -R-10/13/18/38
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,19,black+jLB -Gwhite@60 >> $ps << EOF
-8.5 31.0 M O R O C C O
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
-F+jTL+f17p,19,black+jLB -Gwhite@90 >> $ps << EOF
-5.0 27.0 A      L      G      E      R      I      A
EOF
# GEOGRAPHY
gmt pstext -R -J -N -O -K \
-F+f11p,23,darkred+jLB+a30 -Gwhite@70 >> $ps << EOF
-6.3 31.60 A T L A S  M O U N T A I N S
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,lightyellow+jLB+a30 >> $ps << EOF
-1.30 33.40 High Plateau
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,ivory1+jLB+a30 >> $ps << EOF
-1.60 34.50 Trara Mts
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,ivory1+jLB+a30 >> $ps << EOF
-1.30 34.1 Tlemcen
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,ivory1+jLB+a30 >> $ps << EOF
0.20 35.8 Dahra
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,darkred+jLB+a20 -Gwhite@60 >> $ps << EOF
1.50 35.6 T e l l  A t l a s
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,darkred+jLB >> $ps << EOF
6.10 31.5 Grand Erg
6.10 31.1 Oriental
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,darkred+jLB >> $ps << EOF
0.20 31.5 Grand Erg
0.20 31.1 Occidental
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,darkred+jLB >> $ps << EOF
5.80 29.6 Erg
5.00 29.2 Issaouane
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,23,lightyellow+jLB >> $ps << EOF
5.30 23.20 Hoggar
5.30 22.70 Mountains
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,23,darkbrown+jLB >> $ps << EOF
0.50 20.50 Adrar des Ifoghas
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,23,darkred+jLB -Gnavajowhite3@70 >> $ps << EOF
2.10 28.60 Tademaït
2.10 28.20 Plateau
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,23,darkred+jLB >> $ps << EOF
-5.00 26.60 El Eglab
-5.00 26.20 Massif
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,23,darkbrown+jLB >> $ps << EOF
-5.50 24.50 Erg Chech
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,23,darkbrown+jLB >> $ps << EOF
-5.50 27.60 Erg Iguidi
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,23,lightyellow+jLB+a-33 >> $ps << EOF
7.00 26.10 Tassili n'Ajjer Plateau
EOF
# chotts
gmt pstext -R -J -N -O -K \
-F+f10p,23,blue1+jLB -Gwhite@80 >> $ps << EOF
6.20 34.30 Chott
6.20 33.90 Melrhir
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,23,blue1+jLB -Gwhite@80 >> $ps << EOF
4.10 35.60 Chott
4.10 35.20 el Hodna
EOF

# insert map
gmt psbasemap -R -J -O -K -DjBR+w3.2c+o-0.2c/-0.2c+stmp >> $ps
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
