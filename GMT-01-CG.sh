#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: Congo)
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert
# http://soliton.vm.bytemark.co.uk/pub/cpt-city/njgs/index.html

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
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R11/32/-14/6 -GCD_relief1.nc
gmt grdcut GEBCO_2019.nc -R11/32/-14/6 -GCD_relief.nc

gmt grdgdal -Ainfo CD_relief.nc
# z#actual_range={-4131,4503}

#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R11/32/-14/6 -JM6.5i -Dh -M -ECD > Congo.txt
#####################################################################

# Make color palette
# gmt makecpt -CGeo -V -T-4131/4503 > pauline.cpt
gmt makecpt -CGMT_topo.cpt -V -T-4131/4503 > pauline.cpt
# elevation etopo1 world elevation dem1 dem2 dem3 globe geo srtm turbo terra earth relief costa-rica

ps=Topo_CD.ps
# Make background transparent image
gmt grdimage CD_relief.nc -Cpauline.cpt -R11/32/-14/6 -JM6.5i -I+a15+ne0.75 -t50 -Xc -P -K > $ps
    
# Add isolines
gmt grdcontour CD_relief1.nc -R -J -C1000 -A1000+f7p,26,darkbrown -Wthinner,darkbrown -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,red -W0.1p -Df -O -K >> $ps
    
#####################################################################
# CLIPPING
# 1. Start: clip the map by mask to only include country
#gmt psclip -JM -R Malawi.txt -O -K >> $ps

gmt psclip -R11/32/-14/6 -JM6.5i Congo.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage CD_relief.nc -Cpauline.cpt -R11/32/-14/6 -JM6.5i -I+a15+ne0.75 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour CD_relief1.nc -R -J -C250 -Wthinnest,darkbrown -O -K >> $ps
# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps
#gmt pscoast -R -J \
    -Ia/thinner,blue -Na -W0.1p -Df -O -K >> $ps

# 3: Undo the clipping
gmt psclip -C -O -K >> $ps
#####################################################################
    
# Add color legend
gmt psscale -Dg11.0/-15.5+w16.5c/0.15i+h+o0.3/0i+ml+e -R -J -Cpauline.cpt \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_TITLE=6p,0,black \
    -Bg500f50a500+l"Colormap: 'GMT topo' scheme for elevation [R=-4131/4503, mixed, HSV, 20 segments]" \
    -I0.2 -By+lm -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=WEsN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    -Bpxg4f2a2 -Bpyg4f2a2 -Bsxg4 -Bsyg4 \
    --MAP_TITLE_OFFSET=0.8c \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --FONT_LABEL=8p,25,black \
    --FONT_TITLE=16p,25,black \
    -B+t"Study area: Democratic Republic of the Congo" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=9p,0,black \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx14.5c/-2.5c+c10+w500k+l"Mercator projection. Scale (km)"+f \
    -UBL/0p/-68p -O -K >> $ps

# Texts
# Cities
gmt pstext -R -J -N -O -K \
-F+f14p,22,black+jLB -Gwhite@50 >> $ps << EOF
15.55 -4.50 Kinshasa
EOF
gmt psxy -R -J -Ss -W0.5p -Gred -O -K << EOF >> $ps
15.32 -4.32 0.30c
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,21,black+jLB -Gwhite@50 >> $ps << EOF
23.9 -6.45 Mbuji-Mayi
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
23.6 -6.15 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,21,black+jLB -Gwhite@50 >> $ps << EOF
27.48 -11.60 Lubumbashi
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
27.48 -11.66 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,21,black+jLB -Gwhite@50 >> $ps << EOF
22.50 -5.80 Kananga
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
22.45 -5.92 0.20c
EOF
#gmt pstext -R -J -N -O -K \
#-F+f13p,21,black+jLB -Gwhite@50 >> $ps << EOF
#25.2 0.60 Kisangani
#EOF
gmt pstext -R -J -N -O -K \
-F+f14p,21,white+jLB >> $ps << EOF
22.7 0.10 Kisangani
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
25.2 0.52 0.25c
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,21,black+jLB -Gwhite@50 >> $ps << EOF
27.0 -2.4 Bukavu
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
28.87 -2.5 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,21,black+jLB -Gwhite@50 >> $ps << EOF
20.9 -6.55 Tshikapa
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
20.8 -6.42 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,21,black+jLB -Gwhite@50 >> $ps << EOF
29.50 1.70 Bunia
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
30.25 1.57 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f14p,21,white+jLB >> $ps << EOF
22.47 2.37 Bumba
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
22.47 2.18 0.25c
EOF
gmt pstext -R -J -N -O -K \
-F+f14p,21,white+jLB >> $ps << EOF
23.6 1.37 Basoko
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
23.6 1.23 0.25c
EOF

# countries -R11/32/-14/6
gmt pstext -R -J -N -O -K \
-F+jTL+f23p,29,black+jLB -Gwhite@85 >> $ps << EOF
17.5 -3.0 D.  R.  C  O  N  G  O
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,25,black+jLB -Gwhite@60 >> $ps << EOF
11.8 -0.5 GABON
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,25,black+jLB -Gwhite@60 >> $ps << EOF
14.8 0.5 REPUBLIC
14.8 -0.5 OF THE
14.8 -1.5 CONGO
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,25,black+jLB -Gwhite@60 >> $ps << EOF
24.2 -13.0 Z A M B I A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,25,black+jLB -Gwhite@60 >> $ps << EOF
29 -10 Z A M B I A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,25,black+jLB+a90 -Gwhite@60 >> $ps << EOF
31.3 -7.0 TANZANIA
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,25,black+jLB -Gwhite@60 >> $ps << EOF
29 -3.4 BURUNDI
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,25,black+jLB -Gwhite@60 >> $ps << EOF
29.5 -1.9 RWANDA
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,25,black+jLB+a45 -Gwhite@60 >> $ps << EOF
30 -1.0 UGANDA
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,25,black+jLB -Gwhite@60 >> $ps << EOF
27.8 5.0 SOUTH SUDAN
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,25,black+jLB -Gwhite@60 >> $ps << EOF
15.5 5.5 CENTRAL AFRICAN REPUBLIC
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,25,black+jLB -Gwhite@60 >> $ps << EOF
11.8 3 CAMEROON
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,25,black+jLB -Gwhite@60 >> $ps << EOF
16.2 -11.7 A  N  G  O  L  A
EOF
# water
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,26,blue+jLB >> $ps << EOF
11.2 -8.4 Atlantic
11.2 -9.0 Ocean
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,26,honeydew+jLB+a8 >> $ps << EOF
19.8 1.25 Congo
EOF
#------------ Study area square: start --------------#
# Rotated rectangle. kwargs: coords, direction degrees, x and y-dimension
gmt psxy -R -J -Sj1c -W2.0p,yellow -O -K << EOF >> $ps
23.6 1.30 0 3.0 3.0
EOF
#------------ Study area square: end ----------------#

# insert map
# Countries codes: ISO 3166-1 alpha-2. Continent codes AF (Africa), AN (Antarctica), AS (Asia), EU (Europe), OC (Oceania), NA (North America), or SA (South America). -EEU+ggrey
gmt psbasemap -R -J -O -K -DjBL+w3.2c+o-0.2c/-0.2c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thinnest,grey -Rg -JG28.0/-2.0S/$w -Da -Glightgoldenrod1 -A5000 -Bga -Wfaint -ECD+gred -Sdodgerblue -O -K -X$x0 -Y$y0 >> $ps
#gmt pscoast -Rg -JG12/5N/$w -Da -Gbrown -A5000 -Bg -Wfaint -ECM+gbisque -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx7.1/-2.9+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y10.6c -N -O \
    -F+f10p,0,black+jLB >> $ps << EOF
2.0 9.2 Digital elevation data: GEBCO/SRTM, 15 arc sec (ca. 450 m) resolution grid
EOF

# Convert to image file using GhostScript
gmt psconvert Topo_CD.ps -A0.5c -E720 -Tj -Z
