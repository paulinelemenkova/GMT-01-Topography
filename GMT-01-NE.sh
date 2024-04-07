#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: Niger)
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert

exec bash

# Extract a subset of ETOPO1m for the study area
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R0/17/11/24 -Gne1_relief.nc
gmt grdcut GEBCO_2023.nc -R0/17/11/24 -Gne_relief.nc
gmt grdinfo -M ne1_relief.nc
# Topography: Minimum=78, Maximum=2966

# Make color palette
gmt makecpt -Cgeo -V -T78/2966 > pauline.cpt
# elevation etopo1 world elevation dem1 dem2 dem3 globe geo srtm turbo terra earth

#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R0/17/11/24 -JM6.5i -Dh -M -ENE > Niger.txt
#####################################################################

ps=Topo_NE.ps
# Make background transparent image
gmt grdimage ne1_relief.nc -Cpauline.cpt -R0/17/11/24 -JM6.5i -I+a15+ne0.75 -t40 -Xc -P -K > $ps
.5i
# Add isolines
gmt grdcontour ne1_relief.nc -R -J -C250 -A250+f7p,26,darkbrown -Wthinner,darkbrown -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps
# Add lakes
gmt pscoast -R -J -Ia/thinner,blue -Na -Sroyalblue1 -W2/thin,blue,0.1p -Df -O -K >> $ps
#------------------------->
# CLIPPING
# 1. Start: clip the map by mask to only include country
gmt psclip -R0/17/11/24 -JM6.5i Niger.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage ne1_relief.nc -Cpauline.cpt -R0/17/11/24 -JM6.5i -I+a15+ne0.75 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour ne1_relief.nc -R -J -C250 -A250+f7p,26,darkbrown -Wthinnest,darkbrown -O -K >> $ps
# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps
# Add lakes
gmt pscoast -R -J -Ia/thinner,blue -Na -Sroyalblue1 -W2/thin,blue,0.1p -Df -O -K >> $ps
# 3: Undo the clipping
gmt psclip -C -O -K >> $ps
#-------------------------<
    
# Add color legend -R0/17/11/24
gmt psscale -Dg0/9.8+w16.0c/0.15i+h+o0.3/0i+ml+e -R -J -Cpauline.cpt \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --FONT_TITLE=7p,0,black \
    -Bg500f50a500+l"Colormap: 'geo' Colors for global topography relief [R=-3797/1816, H, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=WEsN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    --MAP_FRAME_PEN=dimgray \
    --MAP_FRAME_WIDTH=0.1c \
    --MAP_TITLE_OFFSET=0.7c \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --FONT_LABEL=8p,25,black \
    --FONT_TITLE=13p,0,black \
        -Bpxg4f1a2 -Bpyg4f2a2 -Bsxg2 -Bsyg2 \
    -B+t"Topographic map of Niger" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=9p,0,black \
    --FONT_ANNOT_PRIMARY=9p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx14.0c/-2.4c+c10+w500k+l"Mercator projection. Scale (km)"+f \
    -UBL/0p/-70p -O -K >> $ps

# Study area -1
# Scene Center Lat DMS     14°27'24.95"N
# Scene Center Long DMS     1°53'20.22"E
# Rotated rectangle. kwargs: coords, direction degrees, x and y-dimension
gmt psxy -R -J -Sj-13/1.8/1.8 -W1.5p,yellow1 -O -K << EOF >> $ps
1.88 14.45
EOF
# Study area -2
# Scene Center Lat DMS    18°47'14.42"N
# Scene Center Long DMS     9°02'00.38"E
# Rotated rectangle. kwargs: coords, direction degrees, x and y-dimension
gmt psxy -R -J -Sj-13/1.8/1.8 -W1.5p,yellow1 -O -K << EOF >> $ps
9.03 18.78
EOF
# Study area -3
# Scene Center Lat DMS    21°40'17.80"N
# Scene Center Long DMS     12°47'19.32"E
# Rotated rectangle. kwargs: coords, direction degrees, x and y-dimension
gmt psxy -R -J -Sj-13/1.8/1.8 -W1.5p,yellow1 -O -K << EOF >> $ps
12.79 21.67
EOF

# Texts
# countries
gmt pstext -R -J -N -O -K \
-F+jTL+f20p,19,azure4+jLB >> $ps << EOF
5.2 16.2 N       I        G       E       R
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,19,darkslategray+jLB -Glemonchiffon2@50 >> $ps << EOF
1.0 17.0 M  A  L  I
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,19,darkslategray+jLB+a40 -Gburlywood@60 >> $ps << EOF
5.0 20.5 A L G E R I A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,19,darkslategray+jLB -Gburlywood@60 >> $ps << EOF
13.0 23.5 L I B Y A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,19,darkslategray+jLB >> $ps << EOF
14.5 15.0 C H A D
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,19,darkslategray+jLB -Glemonchiffon2@50 >> $ps << EOF
7.0 11.8 N I G E R I A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,19,darkslategray+jLB -Glemonchiffon2@50 >> $ps << EOF
1.9 11.1 BENIN
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,19,darkslategray+jLB+a-50 -Glemonchiffon2@50 >> $ps << EOF
0.2 13.4 BURKINA
0.3 12.5 FASO
EOF
# cities
gmt pstext -R -J -N -O -K \
-F+f12p,0,mintcream+jLB -Gsaddlebrown@80 >> $ps << EOF
-12.46 23.03 Zouérat
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-12.46 22.73 0.25c
EOF
# geography
gmt pstext -R -J -N -O -K \
-F+f13p,22,white+jLB -Ggoldenrod@75 >> $ps << EOF
8.6 19.0 Aïr
8.3 18.5 Massif
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,22,white+jLB -Ggoldenrod@75 >> $ps << EOF
12.35 21.70 Djado
12.25 21.30 Plateau
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,21,white+jLB+a30 -Ggoldenrod@75 >> $ps << EOF
8.1 14.20 Damergou
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,22,white+jLB+a40 -Ggoldenrod@80 >> $ps << EOF
10.1 16.6 Ténéré Desert
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,21,white+jLB+a30 -Ggoldenrod@80 >> $ps << EOF
7.85 16.25 Tiguidit
7.85 15.85 Escarpment
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,2,oldlace+jLB -Ggoldenrod@80 >> $ps << EOF
13.8 19.8 Erg of
13.8 19.4 Bilma
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,2,oldlace+jLB -Ggoldenrod@80 >> $ps << EOF
10.08 14.46 Koutous
10.08 14.06 Hill
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,2,oldlace+jLB -Ggoldenrod@80 >> $ps << EOF
14.0 21.5 Tchigaï
14.0 21.1 Plateau
EOF
gmt pstext -R -J -N -O -K \
-F+f18p,20,floralwhite+jLB >> $ps << EOF
7.8 20.2 S     A     H     A     R     A
EOF
gmt pstext -R -J -N -O -K \
-F+f18p,20,floralwhite+jLB >> $ps << EOF
6.7 13.6 S     A     H     E     L
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,23,cornsilk1+jLB >> $ps << EOF
8.05 17.50 Idoukal-n-
8.05 17.10 Taghès Mt.
EOF
gmt psxy -R -J -St -W0.5p -Gred -O -K << EOF >> $ps
8.72 17.84 0.30c
EOF
# rivers
gmt pstext -R -J -N -O -K \
-F+f14p,23,azure+jLB+a-45 -Gpalegreen3@60 >> $ps << EOF
1.55 14.4 Niger
EOF
gmt pstext -R -J -N -O -K \
-F+f14p,23,azure+jLB >> $ps << EOF
12.5 14.5 Chad
12.5 14.1 Lake
EOF

# insert map
# Countries codes: ISO 3166-1 alpha-2. Continent codes AF (Africa), AN (Antarctica), AS (Asia), EU (Europe), OC (Oceania), NA (North America), or SA (South America). -EEU+ggrey -R0/17/11/24
gmt psbasemap -R -J -O -K -DjTL+w3.5c+o-0.2c/-0.2c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thin,grey -Rg -JG9.0/16.0N/$w -Da -Glightgoldenrod1 -A5000 -Bga -Wfaint -ENE+gred -Sdodgerblue -O -K -X$x0 -Y$y0 >> $ps
#gmt pscoast -Rg -JG12/5N/$w -Da -Gbrown -A5000 -Bg -Wfaint -ECM+gbisque -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx7.0/-3.1+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y7.0c -N -O \
    -F+f10p,0,black+jLB >> $ps << EOF
2.5 10.4 Digital elevation data: SRTM/GEBCO, 15 arc sec resolution grid
EOF

# Convert to image file using GhostScript
gmt psconvert Topo_NE.ps -A0.5c -E720 -Tj -Z
