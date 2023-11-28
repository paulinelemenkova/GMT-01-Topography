#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: Mali)
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert
# http://soliton.vm.bytemark.co.uk/pub/cpt-city/esri/hillshade/tn/illumination.png.index.html

exec bash

# Extract a subset of ETOPO1m for the study area
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R15/33/-37/-22 -Gza1_relief.nc
gmt grdcut GEBCO_2023.nc -R15/33/-37/-22 -Gza_relief.nc
gdalinfo -stats za_relief.nc
# Minimum=-4282.000, Maximum=3439.000, Mean=588.405, StdDev=1263.402

# Make color palette
#gmt makecpt -Cgeo -V -T-4430/2533 > pauline.cpt
#gmt makecpt -Cturbo -V -T-4430/2533 > pauline.cpt
#gmt makecpt -Cetopo1 -V -T-4430/2533  > pauline.cpt
#gmt makecpt -Cterra -V -T-4430/2533 > pauline.cpt
gmt makecpt -Cearth -V -T-4282/3439 > pauline.cpt
#gmt makecpt -Cdem1 -V -T-4430/2533 > pauline.cpt

# gmt makecpt -Cafrikakarte -V -T-3395/1000 > pauline.cpt
# gmt makecpt -Cillumination -V -T-5000/500 -Ic > pauline.cpt
# gmt makecpt -Cwiki-1.02.cpt -V -T-3000/500 > pauline.cpt
# elevation etopo1 world elevation dem1 dem2 dem3 globe geo srtm turbo terra earth

#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R15/33/-37/-22 -JM6.5i -Dh -M -EZA > SouthAfrica.txt
#####################################################################

ps=Topo_ZA.ps
# Make background transparent image
gmt grdimage za_relief.nc -Cpauline.cpt -R15/33/-37/-22 -JM6.5i -I+a15+ne0.75 -t40 -Xc -P -K > $ps

# Add isolines
gmt grdcontour za1_relief.nc -R -J -C500 -A1000+f7p,26,darkbrown -Wthinner,darkbrown -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps
# Add lakes
# gmt pscoast -R -J -Ia/thinner,blue -Na -Sroyalblue1 -W2/thin,blue,0.1p -Df -O -K >> $ps
    
#------------------------->
# CLIPPING
# 1. Start: clip the map by mask to only include country
gmt psclip -R15/33/-37/-22 -JM6.5i SouthAfrica.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage za_relief.nc -Cpauline.cpt -R15/33/-37/-22 -JM6.5i -I+a15+ne0.75 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour za1_relief.nc -R -J -C500 -A1000+f7p,26,darkbrown -Wthinnest,darkbrown -O -K >> $ps
# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps
# add lakes
#gmt pscoast -R -J -Ia/thinner,blue -Na -Sroyalblue1 -W2/thin,blue,0.1p -Df -O -K >> $ps

# 3: Undo the clipping
gmt psclip -C -O -K >> $ps
#-------------------------<
    
# Add color legend
gmt psscale -Dg12.5/-37+w15.5c/0.15i+v+o0.3/0i+ml+e -R -J -Cpauline.cpt \
    --FONT_LABEL=9p,0,black \
    --FONT_ANNOT_PRIMARY=9p,0,black \
    --FONT_TITLE=8p,0,black \
    -Bg1000f100a1000+l"Colormap: 'earth' - colors for global bathymetry/topography relief [R=-4430/2533, H, C=RGB]" \
    -I0.2 -By+l"m" -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=wEsN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    --MAP_FRAME_PEN=dimgray \
    --MAP_FRAME_WIDTH=0.1c \
    --MAP_TITLE_OFFSET=0.7c \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --FONT_LABEL=8p,25,black \
    --FONT_TITLE=12p,0,black \
        -Bpxg2f1a2 -Bpyg2f1a2 -Bsxg2 -Bsyg1 \
    -B+t"Topographic map of SouthAfrica" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=9p,0,black \
    --FONT_ANNOT_PRIMARY=9p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx14.5c/-1.3c+c10+w400k+l"Mercator projection. Scale (km)"+f \
    -UBL/0p/-30p -O -K >> $ps

# Study area
# Rotated rectangle. kwargs: -Sjdirection/width/height, coords

# Texts
gmt pstext -R -J -N -O -K \
-F+f15p,29,honeydew+jLB >> $ps << EOF
19.0 -30.4 S  O  U  T  H    A  F  R  I  C  A
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,29,gray25+jLB >> $ps << EOF
16.7 -24.8 N A M I B I A
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,29,gray25+jLB >> $ps << EOF
21.0 -23.9 B O T S W A N A
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,29,gray25+jLB+a90 >> $ps << EOF
32.5 -26.2 MOZAMBIQUE
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,29,white+jLB >> $ps << EOF
27.4 -29.8 LESOTHO
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,29,gray25+jLB -Gwhite@40 >> $ps << EOF
31.0 -26.8 ESWATINI
EOF
gmt pstext -R -J -N -O -K \
-F+f14p,23,white+jLB >> $ps << EOF
15.4 -35.5 A T L A N T I C
15.4 -36.0 O C E A N
EOF
gmt pstext -R -J -N -O -K \
-F+f14p,23,white+jLB >> $ps << EOF
25.8 -35.5 I N D I A N
25.8 -36.0 O C E A N
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,26,blue+jLB >> $ps << EOF
16.7 -31.9 Saint
16.7 -32.3 Helena
16.9 -32.7 Bay
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,26,blue+jLB >> $ps << EOF
22.3 -34.5 Mossel
22.3 -34.9 Bay
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,26,blue+jLB+a-45 >> $ps << EOF
18.7 -34.6 False Bay
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,23,blue+jLB+a40 >> $ps << EOF
22.80 -29.40 Orange
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,23,blue+jLB+a40 >> $ps << EOF
27.30 -23.40 Limpopo
EOF
#
# cities
gmt pstext -R -J -N -O -K \
-F+f11p,0,black+jLB >> $ps << EOF
25.10 -26.30 Johannesburg
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
28.04 -26.20 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,0,black+jLB -Gwhite@50 >> $ps << EOF
18.52 -33.83 Cape Town
EOF
gmt psxy -R -J -Sc -W0.5p -Gred -O -K << EOF >> $ps
18.42 -33.93 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,0,black+jLB -Gwhite@50 >> $ps << EOF
31.15 -29.78 Durban
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
31.05 -29.88 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,0,black+jLB -Gwhite@50 >> $ps << EOF
28.30 -25.80 Pretoria
EOF
gmt psxy -R -J -Sc -W0.5p -Gred -O -K << EOF >> $ps
28.18 -25.75 0.25c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,0,black+jLB -Gwhite@60 >> $ps << EOF
25.6 -34.25 Gqeberha
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
25.6 -33.95 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,0,black+jLB -Gwhite@70 >> $ps << EOF
28.03 -26.87 Vereeniging
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
27.93 -26.67 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,0,black+jLB -Gwhite@60 >> $ps << EOF
25.64 -25.76 Mafikeng
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
25.64 -25.86 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,0,black+jLB -Gwhite@60 >> $ps << EOF
27.20 -25.32 Soshanguve
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
28.10 -25.52 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,0,white+jLB >> $ps << EOF
28.20 -33.22 East London
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
27.90 -33.02 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,0,white+jLB >> $ps << EOF
29.83 -31.83 Port St.Johns
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
29.53 -31.63 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,0,white+jLB >> $ps << EOF
30.65 -30.80 Port
30.65 -31.10 Shepstone
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
30.45 -30.75 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,0,black+jLB >> $ps << EOF
24.22 -29.41 Bloemfontein
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
26.22 -29.11 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,0,black+jLB >> $ps << EOF
24.76 -28.60 Kimberly
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
24.76 -28.74 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,0,black+jLB -Gwhite@60 >> $ps << EOF
16.07 -29.65 Port
15.67 -29.95 Nolloth
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
16.87 -29.25 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,0,black+jLB >> $ps << EOF
15.08 -28.98 Alesander
15.48 -29.30 Bay
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
16.48 -28.58 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,0,black+jLB -Gwhite@60 >> $ps << EOF
18.04 -32.99 Saldanha
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
17.94 -32.99 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,0,black+jLB -Gwhite@60 >> $ps << EOF
18.36 -31.04 Bitterfontein
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
18.26 -31.04 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,0,black+jLB -Gwhite@60 >> $ps << EOF
22.45 -33.76 George
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
22.45 -33.96 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,0,black+jLB -Gwhite@60 >> $ps << EOF
18.96 -34.24 Stellenbosch
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
18.86 -33.94 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,0,black+jLB -Gwhite@60 >> $ps << EOF
20.22 -31.43 Williston
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
20.92 -31.53 0.20c
EOF
#
# geography
gmt pstext -R -J -N -O -K \
-F+f12p,23,darkred+jLB+a10 -Gwhite@70 >> $ps << EOF
21.00 -32.30 G r e a t
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,darkred+jLB -Gwhite@70 >> $ps << EOF
23.40 -32.00 K a r o o
EOF
gmt pstext -R -J -N -O -K \
-F+f17p,20,salmon4+jLB >> $ps << EOF
20.4 -26.2 K A L A H A R I
20.4 -26.9 D E S E R T
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,darkred+jLB+a50 >> $ps << EOF
28.00 -29.10 DRAKENSBERG
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,darkred+jLB+a30 -Gwhite@70 >> $ps << EOF
27.30 -24.80 Witwatersrand Mts.
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,darkred+jLB>> $ps << EOF
23.60 -27.80 KAAP
23.00 -28.30 PLATEAU
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,azure1+jLB >> $ps << EOF
16.40 -33.80 Cape of
16.20 -34.30 Good Hope
EOF
#
# Study area
# Rotated rectangle. kwargs: -Sjdirection/width/height, coords
gmt psxy -R -J -Sj-13/2.3/2.3 -W1.7p,red -O -K << EOF >> $ps
19.00 -33.00
EOF
#gmt pstext -R -J -N -O -K \
#-F+f11p,0,red+jLB >> $ps << EOF
#19.6 -32.80 Study
#19.6 -33.20 Area
#EOF

# insert map
# Countries codes: ISO 3166-1 alpha-2. Continent codes AF (Africa), AN (Antarctica), AS (Asia), EU (Europe), OC (Oceania), NA (North America), or SA (South America). -EEU+ggrey
gmt psbasemap -R -J -O -K -DjBR+w3.5c+o-0.2c/-0.2c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thinnest,lightgray --MAP_FRAME_PEN=thick,white -Rg -JG24.0/30.0S/$w -Da -Glightgoldenrod1 -A5000 -Bga -Wfaint -EZA+gred -Sroyalblue1 -O -K -X$x0 -Y$y0 >> $ps
#gmt pscoast -Rg -JG12/5N/$w -Da -Gbrown -A5000 -Bg -Wfaint -ECM+gbisque -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx7.0/-1.8+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y9.5c -N -O \
    -F+f11p,0,black+jLB >> $ps << EOF
2.5 11.0 Digital elevation data: SRTM/GEBCO, 15 arc sec resolution grid
EOF

# Convert to image file using GhostScript
gmt psconvert Topo_ZA.ps -A0.5c -E720 -Tj -Z
