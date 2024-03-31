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
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R82/88/17/23 -Gin1_relief.nc
gmt grdcut GEBCO_2023.nc -R82/88/17/23 -Gin_relief.nc
gmt grdinfo -M in1_relief.nc
# Minimum=-3258.000, Maximum=1433.000

# Make color palette
#gmt makecpt -Cterra -V -T-7795/8271 > pauline.cpt
gmt makecpt -Cgeo -V -T-2922/1433 > pauline.cpt
#gmt makecpt -Cturbo -V -T-5141/4038 > pauline.cpt
# elevation etopo1 world elevation dem1 dem2 dem3 globe geo srtm turbo terra earth

#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R82/88/17/23 -JM6.5i -Dh -M -EIN > IN.txt
#####################################################################

ps=Topo_IN_Chilika.ps
# Make background transparent image

gmt grdimage in_relief.nc -Cpauline.cpt -R82/88/17/23 -JM6.5i -I+a15+ne0.75 -Xc -P -K > $ps

# Add isolines
gmt grdcontour in1_relief.nc -R -J -C1000 -Wthinnest,darkbrown -O -K >> $ps

# Add coastlines, borders, rivers, lakes
gmt pscoast -R -J -Ia/thinnest,blue -Na -N1/thick,tomato -W0.1p -Df -O -K >> $ps

# Add lakes
# gmt pscoast -R -J -Ia/thinner,blue -Na -Sroyalblue1 -W2/thin,blue,0.1p -Df -O -K >> $ps
    
# Add color legend -R82/88/17/23
gmt psscale -Dg82/16.6+w16.0c/0.15i+h+o0.3/0i+ml+e -R -J -Cpauline.cpt \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --FONT_TITLE=8p,0,black \
    -Bg1000f50a500+l"Colormap: 'geo' colormap for topography [R=-5398/8271, H, C=RGB]" \
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
    -Bpxf2a1g1 -Bpyf2a1g1 -Bsxg2 -Bsyg2 \
    -B+t"Enlarged fragment of the Odisha State, India: coastal zone and Chilika Lake" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=9p,0,black \
    --FONT_ANNOT_PRIMARY=9p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx14.5c/-2.5c+c10+w200k+l"Mercator Projection. Scale (km)"+f \
    -UBL/0p/-70p -O -K >> $ps

# Texts
# countries

# water
gmt pstext -R -J -N -O -K \
-F+jTL+f16p,23,white+jLB >> $ps << EOF
84.6 17.3 I  N  D  I  A  N    O  C  E  A  N
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f16p,2,azure+jLB >> $ps << EOF
86.3 18.5 B a y   o f
86.3 18.2 B e n g a l
EOF
# cities
gmt pstext -R -J -N -O -K \
-F+f13p,0,white+jLB >> $ps << EOF
85.25 20.07 Bhubaneswar
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
85.84 20.27 0.25c
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,0,white+jLB >> $ps << EOF
85.83 19.71 Puri
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
85.83 19.81 0.25c
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,0,black+jLB -Gwhite@50 >> $ps << EOF
83.89 19.35 Brahmapur
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
84.79 19.31 0.25c
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,0,white+jLB >> $ps << EOF
86.30 20.86 Bhadrak
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
86.50 21.06 0.25c
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,0,white+jLB >> $ps << EOF
86.55 21.60 Balasore
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
86.92 21.50 0.25c
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,0,white+jLB >> $ps << EOF
83.97 21.47 Sambalpur
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
83.97 21.37 0.25c
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,0,black+jLB -Gwhite@50 >> $ps << EOF
84.88 22.05 Rourkela
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
84.88 22.25 0.25c
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,0,white+jLB >> $ps << EOF
82.07 18.96 Jeypore
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
82.57 18.86 0.25c
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,0,black+jLB -Gnavajowhite1@50 >> $ps << EOF
85.29 20.62 Cuttack
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
85.79 20.52 0.25c
EOF
# rivers
gmt pstext -R -J -N -O -K \
-F+f14p,6,blue1+jLB+a-30 -Gnavajowhite1@60 >> $ps << EOF
84.70 20.70 Mahanadi
EOF
gmt pstext -R -J -N -O -K \
-F+f14p,6,blue1+jLB+a43 -Gnavajowhite1@50 >> $ps << EOF
83.30 20.33 Tel River
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,23,blue1+jLB+a-60 -Gnavajowhite1@60 >> $ps << EOF
85.02 21.45 Brahmani
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,23,blue1+jLB+a-67 -Gnavajowhite1@70 >> $ps << EOF
85.85 21.90 Baitarani
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,blue1+jLB+a-55 -Gnavajowhite1@70 >> $ps << EOF
86.25 22.90 Subarnarekha
EOF
# Mts
gmt pstext -R -J -N -O -K \
-F+f16p,0,cornsilk+jLB+a55 -Gdarkgoldenrod4@70 >> $ps << EOF
82.45 18.10 EASTERN GHATS
EOF
gmt pstext -R -J -N -O -K \
-F+f14p,2,yellow1+jLB+a40 >> $ps << EOF
85.20 19.55 Chilika
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,2,floralwhite+jLB -Gdarkgoldenrod4@60 >> $ps << EOF
83.08 18.72 Deomali
EOF
gmt psxy -R -J -St -W0.5p -Gred -O -K << EOF >> $ps
82.98 18.67 0.35c
EOF
# Study area
# Rotated rectangle. kwargs: -Sjdirection/width/height, coords
# LAT: 20°13'46.99"N LON: 85°02'54.24"E
gmt psxy -R -J -Sj-13/4.5/4.5 -W2.0p,yellow -O -K << EOF >> $ps
85.05 20.23
EOF

# Add GMT logo
gmt logo -Dx7.0/-3.1+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y11.3c -N -O \
    -F+f10p,0,black+jLB >> $ps << EOF
3.0 10.4 Digital elevation data: SRTM/GEBCO, 15 arc sec resolution grid
EOF

# Convert to image file using GhostScript
gmt psconvert Topo_IN_Chilika.ps -A0.5c -E720 -Tj -Z
