#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: Mali)
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert
# http://soliton.vm.bytemark.co.uk/pub/cpt-city/esri/hillshade/tn/illumination.png.index.html

exec bash

# Extract a subset of ETOPO1m for the study area
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R-17/-13.5/10.5/13 -Ggw1_relief.nc
gmt grdcut GEBCO_2023.nc -R-17/-13.5/10.5/13 -Ggw_relief.nc
gmt grdcut GEBCO_2019.nc -R-17/-13.5/10.5/13 -Ggw_relief.nc
gdalinfo -stats gw_relief.nc
# Topography: Minimum=-240.000, Maximum=617.000, Mean=38.238, StdDev=72.152
# Minimum=-216.000, Maximum=679.000, Mean=37.729, StdDev=73.103

# Make color palette
gmt makecpt -Cgeo -V -T-216/679 > pauline.cpt
# gmt makecpt -Cturbo -V -T-3395/1434 > pauline.cpt
# gmt makecpt -Cterra -V -T-3395/1434 > pauline.cpt
# gmt makecpt -Cearth -V -T-3395/1434 > pauline.cpt
# gmt makecpt -Cdem1 -V -T-3395/1434 > pauline.cpt
# gmt makecpt -Cgeo -V -T-3395/1434 > pauline.cpt
# gmt makecpt -Cafrikakarte -V -T-5000/500 > pauline.cpt
# gmt makecpt -Cafrikakarte -V -T-3395/1000 > pauline.cpt
# gmt makecpt -Cillumination -V -T-5000/500 -Ic > pauline.cpt
# gmt makecpt -Cwiki-1.02.cpt -V -T-3000/500 > pauline.cpt
# elevation etopo1 world elevation dem1 dem2 dem3 globe geo srtm turbo terra earth

#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R-17/-13.5/10.5/13 -JM6.5i -Dh -M -EGW > Guinea-Bissau.txt
#####################################################################

ps=Topo_GW.ps
# Make background transparent image
gmt grdimage gw_relief.nc -Cpauline.cpt -R-17/-13.5/10.5/13 -JM6.5i -I+a15+ne0.75 -t40 -Xc -P -K > $ps

# Add isolines
gmt grdcontour gw1_relief.nc -R -J -C50 -A100+f7p,26,darkbrown -Wthinner,darkbrown -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps
# Add lakes
# gmt pscoast -R -J -Ia/thinner,blue -Na -Sroyalblue1 -W2/thin,blue,0.1p -Df -O -K >> $ps
    
#------------------------->
# CLIPPING
# 1. Start: clip the map by mask to only include country
gmt psclip -R-17/-13.5/10.5/13 -JM6.5i Guinea-Bissau.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage gw_relief.nc -Cpauline.cpt -R-17/-13.5/10.5/13 -JM6.5i -I+a15+ne0.75 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour gw1_relief.nc -R -J -C50 -A100+f7p,26,darkbrown -Wthinnest,darkbrown -O -K >> $ps
# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps
# add lakes
#gmt pscoast -R -J -Ia/thinner,blue -Na -Sroyalblue1 -W2/thin,blue,0.1p -Df -O -K >> $ps

# 3: Undo the clipping
gmt psclip -C -O -K >> $ps
#-------------------------<
    
# Add color legend
gmt psscale -Dg-17/10.25+w16.0c/0.15i+h+o0.3/0i+ml+e -R -J -Cpauline.cpt \
    --FONT_LABEL=10p,0,black \
    --FONT_ANNOT_PRIMARY=10p,0,black \
    --FONT_TITLE=8p,0,black \
    -Bg100f10a100+l"Colormap: 'geo', C=RGB" \
    -I0.2 -By+l"m" -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=WEsN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    --MAP_FRAME_PEN=dimgray \
    --MAP_FRAME_WIDTH=0.1c \
    --MAP_TITLE_OFFSET=0.7c \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --FONT_LABEL=8p,25,black \
    --FONT_TITLE=12p,0,black \
        -Bpxg1f0.5a1 -Bpyg1f0.5a1 -Bsxg2 -Bsyg1 \
    -B+t"Topographic map of Guinea-Bissau" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=9p,0,black \
    --FONT_ANNOT_PRIMARY=9p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx14.0c/-2.6c+c10+w100k+l"Mercator projection. Scale (km)"+f \
    -UBL/0p/-70p -O -K >> $ps

# Study area
# Rotated rectangle. kwargs: coords, direction degrees, x and y-dimension
#gmt psxy -R -J -Sj1c -W1.7p,red3 -O -K << EOF >> $ps
#-16.68 14.46 -13 4.0 4.0
#EOF

# Texts
# countries
gmt pstext -R -J -N -O -K \
-F+f16p,29,gray25+jLB -Gwhite@60 >> $ps << EOF
-14.5 11.2 G U I N E A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f16p,29,darkred+jLB -Gwhite@70 >> $ps << EOF
-15.5 12.8 S   E   N   E   G   A   L
EOF

# cities
gmt pstext -R -J -N -O -K \
-F+f14p,1,white+jLB >> $ps << EOF
-15.86 11.90 Bissau
EOF
gmt psxy -R -J -Sa -W0.5p -Gyellow -O -K << EOF >> $ps
-15.56 11.86 0.35c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,0,black+jLB -Gwhite@70 >> $ps << EOF
-14.75 12.07 Bafatá
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-14.65 12.17 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,0,black+jLB -Gwhite@70 >> $ps << EOF
-16.27 12.17 Cacheu
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-16.17 12.27 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,0,black+jLB -Gwhite@70 >> $ps << EOF
-14.18 12.22 Gabu
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-14.22 12.28 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,0,black+jLB -Gwhite@70 >> $ps << EOF
-14.93 11.55 Buba
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-14.99 11.59 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,0,black+jLB -Gwhite@70 >> $ps << EOF
-15.78 11.32 Bubaque
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-15.83 11.28 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,0,black+jLB -Gwhite@70 >> $ps << EOF
-15.20 11.23 Catió
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-15.25 11.28 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,0,black+jLB -Gwhite@70 >> $ps << EOF
-15.25 12.05 Mansôa
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-15.31 12.06 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,0,black+jLB -Gwhite@70 >> $ps << EOF
-15.44 11.62 Bolama
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-15.48 11.58 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,0,black+jLB -Gwhite@70 >> $ps << EOF
-15.70 12.10 Bissorã
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-15.43 12.04 0.20c
EOF
#
# Geography
gmt pstext -R -J -N -O -K \
-F+f14p,23,navyblue+jLB >> $ps << EOF
-16.6 10.80 A T L A N T I C
-16.6 10.65 O C E A N
EOF
# rivers
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,23,azure+jLB+a-28 >> $ps << EOF
-16.05 12.40 Rio Cacheu
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,23,blue+jLB+a49 -Gwhite@70 >> $ps << EOF
-14.74 12.25 Rio Geba
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,23,blue+jLB+a0 -Gwhite@70 >> $ps << EOF
-14.70 11.65 Rio Corubal
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,23,blue+jLB+a36 >> $ps << EOF
-15.85 11.55 Canal do Geba
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,0,black+jLB -Gwhite@70 >> $ps << EOF
-16.60 11.15 Bissagos
-16.60 11.05 Islands
EOF

#
# insert map
# Countries codes: ISO 3166-1 alpha-2. Continent codes AF (Africa), AN (Antarctica), AS (Asia), EU (Europe), OC (Oceania), NA (North America), or SA (South America). -EEU+ggrey
gmt psbasemap -R -J -O -K -DjTL+w3.2c+o-0.2c/-0.2c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thinnest,lightgray --MAP_FRAME_PEN=thick,white -Rg -JG-1.0/8.0N/$w -Da -Glightgoldenrod1 -A5000 -Bga -Wfaint -ESN+gred -Sroyalblue1 -O -K -X$x0 -Y$y0 >> $ps
#gmt pscoast -Rg -JG12/5N/$w -Da -Gbrown -A5000 -Bg -Wfaint -ECM+gbisque -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx7.0/-3.1+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y5.5c -N -O \
    -F+f11p,0,black+jLB >> $ps << EOF
2.5 11.0 Digital elevation data: SRTM/GEBCO, 15 arc sec resolution grid
EOF

# Convert to image file using GhostScript
gmt psconvert Topo_GW.ps -A0.5c -E720 -Tj -Z
