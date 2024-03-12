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
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R41.5/44/10.5/13 -Gdj1_relief.nc
gmt grdcut GEBCO_2023.nc -R41.5/44/10.5/13 -Gdj_relief.nc
gmt grdinfo -M dj_relief.nc
# -1664/1906

# Make color palette
#gmt makecpt -Cterra -V -T-1000/1500 > pauline.cpt
#gmt makecpt -Cetopo1 -V -T-1664/1906 > pauline.cpt
gmt makecpt -Cgeo -V -T-1664/1906 > pauline.cpt
# elevation etopo1 world elevation dem1 dem2 dem3 globe geo srtm turbo terra earth

#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R41.5/44/10.5/13 -JM6.5i -Dh -M -EDJ > DJ.txt
#####################################################################

ps=Topo_DJ.ps
# Make background transparent image

gmt grdimage dj_relief.nc -Cpauline.cpt -R41.5/44/10.5/13 -JM6.5i -I+a15+ne0.75 -t40 -Xc -P -K > $ps

# Add isolines
gmt grdcontour dj1_relief.nc -R -J -C200 -Wthinnest,darkbrown -O -K >> $ps

# Add coastlines, borders, rivers, lakes
gmt pscoast -R -J -Ia/thinnest,blue -Na -N1/thick,tomato -W0.1p -Df -O -K >> $ps

#####################################################################
# CLIPPING
# 1. Start: clip the map by mask to only include country

gmt psclip -R41.5/44/10.5/13 -JM6.5i DJ.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage dj_relief.nc -Cpauline.cpt -R41.5/44/10.5/13 -JM6.5i -I+a15+ne0.75 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour dj1_relief.nc -R -J -C200 -Wthinnest,darkbrown -O -K >> $ps
# Add coastlines, borders, rivers, lakes
gmt pscoast -R -J -Ia/thinnest,blue -Na -N1/thick,tomato -W0.1p -Df -O -K >> $ps
# Add lakes
#gmt pscoast -R -J -Ia/thinner,blue -Na -Sroyalblue1 -W2/thin,blue,0.1p -Df -O -K >> $ps

# 3: Undo the clipping
gmt psclip -C -O -K >> $ps
#####################################################################
    
# Add color legend -R41.5/44/10.5/13
gmt psscale -Dg41.2/10.5+w16.0c/0.15i+v+o0.3/0i+ml+e -R -J -Cpauline.cpt \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --FONT_TITLE=8p,0,black \
    -Bg500f50a500+l"Colormap: 'etopo1' colormap for topography [R=-1000/1500, H, C=RGB]" \
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
    -Bpxf2a0.5g0.5 -Bpyf2a0.5g0.5 -Bsxg1 -Bsyg1 \
    -B+t"Topographic map of Djibouti" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=11p,0,black \
    --FONT_ANNOT_PRIMARY=11p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx14.5c/-1.5c+c10+w100k+l"Mercator Projection. Scale (km)"+f \
    -UBL/0p/-40p -O -K >> $ps

# Texts
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,26,blue+jLB >> $ps << EOF
43.14 12.8 Red Sea
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,26,blue+jLB+a-25 -GLIGHTSKYBLUE1@60 >> $ps << EOF
43.30 12.6 Bab-el-Mandeb
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,26,blue+jLB+a30 -GLIGHTSKYBLUE1@60 >> $ps << EOF
42.76 11.58 Gulf of Tadjoura
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,26,blue+jLB >> $ps << EOF
43.60 11.80 Gulf of
43.62 11.72 Aden
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f13p,0,blue+jLB+a-45 -GLIGHTSKYBLUE1@60 >> $ps << EOF
42.35 11.70 Assal
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,0,blue+jLB >> $ps << EOF
41.70 11.17 Abbe
EOF
# countries
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,19,darkslategray+jLB >> $ps << EOF
42.35 12.70 E R I T R E A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,19,darkslategray+jLB >> $ps << EOF
41.7 10.60 E T H I O P I A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,19,darkslategray+jLB+a-20 >> $ps << EOF
43.55 12.83 Y E M E N
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,19,darkslategray+jLB >> $ps << EOF
43.10 10.8 S O M A L I A
EOF

# Study area
# Rotated rectangle. kwargs: -Sjdirection/width/height, coords
# LAT: 11°34'03.76"N LON: 42°57'36.36"E
gmt psxy -R -J -Sj-13/11.0/11.0 -W2.0p,yellow -O -K << EOF >> $ps
42.96 11.57
EOF
#gmt pstext -R -J -N -O -K \
 #   -F+f14p,2,yellow+jLB >> $ps << EOF
#89.8 23.05 S t u d y     A r e a
#EOF

# Texts
# insert map
gmt psbasemap -R -J -O -K -DjTL+w4.5c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thin,grey --MAP_FRAME_PEN=thin,azure -Rg -JG42/12N/$w -Da -Glightgoldenrod1 -A5000 -Bga -Wfaint -EDJ+gred -Sroyalblue3 -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx7.0/-2.1+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y10.6c -N -O \
    -F+f12p,0,black+jLB >> $ps << EOF
1.5 10.4 Digital elevation data: GEBCO, 15 arc sec resolution grid
EOF

# Convert to image file using GhostScript
gmt psconvert Topo_DJ.ps -A0.5c -E720 -Tj -Z
