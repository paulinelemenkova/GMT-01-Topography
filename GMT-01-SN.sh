#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: Mali)
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert
# http://soliton.vm.bytemark.co.uk/pub/cpt-city/esri/hillshade/tn/illumination.png.index.html

exec bash

# Extract a subset of ETOPO1m for the study area
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R-18/-11/12/17 -Gsn1_relief.nc
gmt grdcut GEBCO_2019.nc -R-18/-11/12/17 -Gsn_relief.nc
gdalinfo -stats sn1_relief.nc
# Topography: Minimum=-3395.000, Maximum=1434.000, Mean=-118.696, StdDev=610.604

# Make color palette
# gmt makecpt -Cgeo -V -T-3395/1434 > pauline.cpt
# gmt makecpt -Cturbo -V -T-3395/1434 > pauline.cpt
# gmt makecpt -Cterra -V -T-3395/1434 > pauline.cpt
# gmt makecpt -Cearth -V -T-3395/1434 > pauline.cpt
# gmt makecpt -Cdem1 -V -T-3395/1434 > pauline.cpt
# gmt makecpt -Cgeo -V -T-3395/1434 > pauline.cpt
# gmt makecpt -Cafrikakarte -V -T-5000/500 > pauline.cpt
# gmt makecpt -Cafrikakarte -V -T-3395/1000 > pauline.cpt
gmt makecpt -Cillumination -V -T-5000/500 -Ic > pauline.cpt
# gmt makecpt -Cwiki-1.02.cpt -V -T-3000/500 > pauline.cpt
# elevation etopo1 world elevation dem1 dem2 dem3 globe geo srtm turbo terra earth

#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R-18/-11/12/17 -JM6.5i -Dh -M -ESN > Senegal.txt
#####################################################################

ps=Topo_SN.ps
# Make background transparent image
gmt grdimage sn_relief.nc -Cpauline.cpt -R-18/-11/12/17 -JM6.5i -I+a15+ne0.75 -t40 -Xc -P -K > $ps
.5i
# Add isolines
gmt grdcontour sn1_relief.nc -R -J -C250 -A250+f7p,26,darkbrown -Wthinner,darkbrown -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps
gmt pscoast -R -J -Ia/thinner,blue -Na -Sroyalblue1 -W2/thin,blue,0.1p -Df -O -K >> $ps
    
#------------------------->
# CLIPPING
# 1. Start: clip the map by mask to only include country
gmt psclip -R-18/-11/12/17 -JM6.5i Senegal.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage sn_relief.nc -Cpauline.cpt -R-18/-11/12/17 -JM6.5i -I+a15+ne0.75 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour sn1_relief.nc -R -J -C100 -A250+f7p,26,darkbrown -Wthinnest,darkbrown -O -K >> $ps
# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps
gmt pscoast -R -J -Ia/thinner,blue -Na -Sroyalblue1 -W2/thin,blue,0.1p -Df -O -K >> $ps

# 3: Undo the clipping
gmt psclip -C -O -K >> $ps
#-------------------------<
    
# Add color legend
gmt psscale -Dg-18/11.5+w16.5c/0.15i+h+o0.3/0i+ml+e -R -J -Cpauline.cpt \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_TITLE=6p,0,black \
    -Bg1000f50a500+l"Colormap: 'illumination', ESRI cartographic and geospatial gradient, continuous, 126 segments, C=RGB" \
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
        -Bpxg4f1a2 -Bpyg4f1a1 -Bsxg2 -Bsyg1 \
    -B+t"Topographic map of Senegal" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=9p,0,black \
    --FONT_ANNOT_PRIMARY=9p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx14.0c/-2.5c+c10+w200k+l"Mercator projection. Scale (km)"+f \
    -UBL/0p/-70p -O -K >> $ps

# Study area
# Rotated rectangle. kwargs: coords, direction degrees, x and y-dimension
gmt psxy -R -J -Sj1c -W1.7p,red3 -O -K << EOF >> $ps
-16.68 14.46 -13 4.0 4.0
EOF

# Texts
# countries
gmt pstext -R -J -N -O -K \
-F+f11p,0,gray25+jLB >> $ps << EOF
-13.95 16.5 M A U R I T A N I A
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,gray25+jLB -Glemonchiffon2@60 >> $ps << EOF
-15.95 13.42 GAMBIA
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,gray25+jLB >> $ps << EOF
-15.95 12.1 G U I N E A - B I S S A U
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,gray25+jLB >> $ps << EOF
-13.7 12.1 G U I N E A
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,0,gray25+jLB >> $ps << EOF
-11.75 14.8 M A L I
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f18p,29,darkred+jLB >> $ps << EOF
-15.8 14.05 S   E   N   E   G   A   L
EOF

# cities
gmt pstext -R -J -N -O -K \
-F+f11p,21,darkred+jLB >> $ps << EOF
-16.85 14.78 Thiès
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-16.92 14.78 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,21,azure2+jLB >> $ps << EOF
-17.50 14.50 Dakar
EOF
gmt psxy -R -J -Sa -W0.5p -Gyellow -O -K << EOF >> $ps
-17.44 14.70 0.35c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,21,darkred+jLB >> $ps << EOF
-16.89 14.32 Mbour
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-16.96 14.42 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,21,darkred+jLB >> $ps << EOF
-16.45 14.48 Diourbel
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-16.23 14.65 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,21,darkred+jLB >> $ps << EOF
-16.45 13.85 Kaolack
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-16.25 14.02 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,21,darkred+jLB >> $ps << EOF
-16.40 15.85 Saint-
-16.40 15.75 Louis
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-16.5 15.90 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,21,darkred+jLB >> $ps << EOF
-16.20 14.86 Touba
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-15.88 14.86 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,21,darkred+jLB >> $ps << EOF
-16.36 12.66 Ziguinchor
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-16.26 12.55 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,21,darkred+jLB >> $ps << EOF
-13.60 13.60 Tambacounda
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-13.67 13.77 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,21,darkred+jLB >> $ps << EOF
-16.45 15.45 Louga
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-16.22 15.62 0.20c
EOF
# Geography
gmt pstext -R -J -N -O -K \
-F+f15p,20,khaki4+jLB >> $ps << EOF
-15.6 14.7 S       A       H          E         L
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,4,gray25+jLB >> $ps << EOF
-15.2 16.30 Ferlo
-15.2 16.15 Desert
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,23,blue1+jLB+a-10 -Glemonchiffon2@50 >> $ps << EOF
-13.1 12.85 Gambia
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,23,blue1+jLB+a-35 >> $ps << EOF
-14.45 16.35 Senegal
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,23,blue1+jLB+a-55 >> $ps << EOF
-13.26 15.95 Senegal
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,23,blue1+jLB+a-75 >> $ps << EOF
-12.45 14.45 Falémé
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,23,blue1+jLB >> $ps << EOF
-15.75 16.30 Lac de
-15.75 16.15 Guiers
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,23,blue1+jLB+a-30 >> $ps << EOF
-15.85 15.95 Vallée du Ferlo
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,23,blue1+jLB+a-13 >> $ps << EOF
-14.60 15.8 Tiangol Louguéré
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,23,blue1+jLB+a-33 >> $ps << EOF
-13.85 15.35 Vallée du Ferlo
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,23,blue1+jLB+a-30 >> $ps << EOF
-14.64 15.07 Vallée de Mboun
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,23,blue1+jLB >> $ps << EOF
-14.90 14.45 Vallée du Saloum
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,23,blue1+jLB+a28 >> $ps << EOF
-14.35 13.65 Sandougou
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,23,blue1+jLB+a-70 >> $ps << EOF
-13.60 13.22 Koulountou
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,23,blue1+jLB+a34 >> $ps << EOF
-13.25 13.75 Nieri-Ko
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,23,blue1+jLB+a28 >> $ps << EOF
-16.60 14.00 Saloum
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,21,ivory1+jLB >> $ps << EOF
-17.95 14.95 Cape Verde
-17.95 14.80 Peninsula
EOF
gmt pstext -R -J -N -O -K \
-F+f14p,23,ivory1+jLB >> $ps << EOF
-17.85 13.05 ATLANTIC
-17.85 12.80 OCEAN
EOF
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
    -F+f10p,0,black+jLB >> $ps << EOF
2.5 11.0 Digital elevation data: SRTM/GEBCO, 15 arc sec resolution grid
EOF

# Convert to image file using GhostScript
gmt psconvert Topo_SN.ps -A0.5c -E720 -Tj -Z
