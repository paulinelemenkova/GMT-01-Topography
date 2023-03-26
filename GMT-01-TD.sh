#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: Chad)
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
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R13/25/7/24 -Gtd1_relief.nc
gmt grdcut GEBCO_2019.nc -R13/25/7/24 -Gtd_relief.nc
gdalinfo -stats td1_relief.nc
# Minimum=78.000, Maximum=3219.000, Mean=571.787, StdDev=248.317

# Make color palette
gmt makecpt -Cgeo -V -T78/3219 > pauline.cpt
# elevation etopo1 world elevation dem1 dem2 dem3 globe geo srtm turbo terra earth

#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R13/25/7/24 -JM6.5i -Dh -M -ETD > TD.txt
#####################################################################

ps=Topo_TD.ps
# Make background transparent image

gmt grdimage td1_relief.nc -Cpauline.cpt -R13/25/7/24 -JM6.5i -I+a15+ne0.75 -t40 -Xc -P -K > $ps

# Add isolines
gmt grdcontour td1_relief.nc -R -J -C250 -A500+f7p,26,darkbrown -Wthinnest,darkbrown -O -K >> $ps

# Add coastlines, borders, rivers, lakes
gmt pscoast -R -J -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps
gmt pscoast -R -J -Ia/thinner,blue -Na -Sroyalblue1 -W2/thin,blue,0.1p -Df -O -K >> $ps
    
#####################################################################
# CLIPPING
# 1. Start: clip the map by mask to only include country

gmt psclip -R13/25/7/24 -JM6.5i TD.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage td1_relief.nc -Cpauline.cpt -R13/25/7/24 -JM6.5i -I+a15+ne0.75 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour td1_relief.nc -R -J -C250 -A500+f7p,26,darkbrown -Wthinnest,darkbrown -O -K >> $ps
# Add coastlines, borders, rivers, lakes
gmt pscoast -R -J -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps
gmt pscoast -R -J -Ia/thinner,blue -Na -Sroyalblue1 -W2/thin,blue,0.1p -Df -O -K >> $ps

# 3: Undo the clipping
gmt psclip -C -O -K >> $ps
#####################################################################
    
# Add color legend -R13/25/7/24
gmt psscale -Dg13/6.1+w16.0c/0.15i+h+o0.3/0i+ml+e -R -J -Cpauline.cpt \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_TITLE=6p,0,black \
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
    -B+t"Topographic map of Chad" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=9p,0,black \
    --FONT_ANNOT_PRIMARY=9p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx14.5c/-2.4c+c10+w300k+l"Mercator projection. Scale (km)"+f \
    -UBL/0p/-70p -O -K >> $ps

# Texts
# countries -R13/25/7/24
gmt pstext -R -J -N -O -K \
-F+jTL+f20p,19,black+jLB -Gwhite@90 >> $ps << EOF
16.1 16.1 C     H     A     D
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,19,black+jLB -Gwhite@70 >> $ps << EOF
17.0 7.3 CENTRAL AFRICAL REPUBLIC
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,19,black+jLB -Gwhite@70 >> $ps << EOF
13.2 7.8 CAMEROON
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,19,black+jLB+a90 -Gwhite@80 >> $ps << EOF
13.5 10.7 N I G E R I A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f15p,19,black+jLB -Gwhite@70 >> $ps << EOF
13.3 19.0 N I G E R
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f15p,19,black+jLB -Gwhite@70 >> $ps << EOF
20.5 22.5 L  I  B  Y  A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f15p,19,black+jLB -Gwhite@70 >> $ps << EOF
22.5 13.0 S U D A N
EOF
# water
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,26,blue1+jLB >> $ps << EOF
14.3 13.7 Lake
14.3 13.4 Chad
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f13p,26,blue1+jLB >> $ps << EOF
17.1 13.3 Lake
17.1 13.0 Fitri
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f13p,26,blue1+jLB >> $ps << EOF
19.7 10.1 Lake
19.7 9.8 Iro
EOF
# rivers
gmt pstext -R -J -N -O -K \
-F+f12p,23,blue1+jLB+a-30 >> $ps << EOF
18.30 13.38 Batha
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,blue1+jLB+a47 >> $ps << EOF
16.32 14.10 Bahr el Ghazal
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,blue1+jLB+a38 >> $ps << EOF
17.50 15.38 (Soro)
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,blue1+jLB+a38 >> $ps << EOF
19.78 10.70 Bahr Salamat
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,blue1+jLB+a-18 >> $ps << EOF
16.20 10.72 Chari
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,blue1+jLB+a-45 >> $ps << EOF
16.05 9.87 Logone
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,blue1+jLB+a5 >> $ps << EOF
19.10 9.10 Bahr Aouk
EOF
# Mts
gmt pstext -R -J -N -O -K \
-F+f12p,23,white+jLB -Gbrown4@70 >> $ps << EOF
17.00 21.00 TIBESTI
17.00 20.60 MOUNTAINS
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,23,white+jLB >> $ps << EOF
16.70 17.35 Bodélé
16.50 17.00 Depression
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,darkred+jLB -Gpalegoldenrod@60 >> $ps << EOF
16.50 18.10 Djurab Desert
EOF
gmt pstext -R -J -N -O -K \
-F+f14p,23,darkred+jLB -Gpalegoldenrod@60 >> $ps << EOF
16.20 19.00 B O R K O U
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,23,brown4+jLB -Gpalegoldenrod@70 >> $ps << EOF
21.10 18.02 Mourdi
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,23,brown4+jLB+a5 -Gpalegoldenrod@70 >> $ps << EOF
22.10 18.02 Depression
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,23,white+jLB -Gbrown4@70 >> $ps << EOF
22.10 17.40 ENNEDI
22.10 17.10 PLATEAU
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,white+jLB+a45 -Gsaddlebrown@70 >> $ps << EOF
21.20 14.30 Kerkour Nourene
23.00 14.60 Massif
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,wheat4+jLB >> $ps << EOF
19.50 17.00 Ouadi-Rimé
19.50 16.60 Ouadi-Hachim
19.60 16.20 Faunal Reserve
EOF


# insert map
gmt psbasemap -R -J -O -K -DjBR+w3.5c+o-0.2c/-0.2c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thin,grey -Rg -JG10/8N/$w -Da -Glightgoldenrod1 -A5000 -Bga -Wfaint -ETD+gred -Sdodgerblue -O -K -X$x0 -Y$y0 >> $ps
#gmt pscoast -Rg -JG12/5N/$w -Da -Gbrown -A5000 -Bg -Wfaint -ECM+gbisque -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx7.0/-3.0+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y18.3c -N -O \
    -F+f10p,0,black+jLB >> $ps << EOF
3.0 10.4 Digital elevation data: SRTM/GEBCO, 15 arc sec resolution grid
EOF

# Convert to image file using GhostScript
gmt psconvert Topo_TD.ps -A0.5c -E720 -Tj -Z
