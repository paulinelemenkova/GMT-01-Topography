#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: Mali)
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert
# http://soliton.vm.bytemark.co.uk/pub/cpt-city/esri/hillshade/tn/illumination.png.index.html

exec bash

# Extract a subset of ETOPO1m for the study area
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R10/25/-19/-4 -Gao1_relief.nc
gmt grdcut GEBCO_2023.nc -R10/25/-19/-4 -Gao_relief.nc
gdalinfo -stats ao_relief.nc
# Minimum=-4430.000, Maximum=2533.000, Mean=458.513, StdDev=1364.345

# Make color palette
#gmt makecpt -Cgeo -V -T-4430/2533 > pauline.cpt
#gmt makecpt -Cturbo -V -T-4430/2533 > pauline.cpt
#gmt makecpt -Cetopo1 -V -T-4430/2533  > pauline.cpt
#gmt makecpt -Cterra -V -T-4430/2533 > pauline.cpt
gmt makecpt -Cearth -V -T-4430/2533 > pauline.cpt
#gmt makecpt -Cdem1 -V -T-4430/2533 > pauline.cpt

# gmt makecpt -Cafrikakarte -V -T-3395/1000 > pauline.cpt
# gmt makecpt -Cillumination -V -T-5000/500 -Ic > pauline.cpt
# gmt makecpt -Cwiki-1.02.cpt -V -T-3000/500 > pauline.cpt
# elevation etopo1 world elevation dem1 dem2 dem3 globe geo srtm turbo terra earth

#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R10/25/-19/-4 -JM6.5i -Dh -M -EAO > Angola.txt
#####################################################################

ps=Topo_AO.ps
# Make background transparent image
gmt grdimage ao_relief.nc -Cpauline.cpt -R10/25/-19/-4 -JM6.5i -I+a15+ne0.75 -t40 -Xc -P -K > $ps

# Add isolines
gmt grdcontour ao1_relief.nc -R -J -C500 -A1000+f7p,26,darkbrown -Wthinner,darkbrown -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps
# Add lakes
# gmt pscoast -R -J -Ia/thinner,blue -Na -Sroyalblue1 -W2/thin,blue,0.1p -Df -O -K >> $ps
    
#------------------------->
# CLIPPING
# 1. Start: clip the map by mask to only include country
gmt psclip -R10/25/-19/-4 -JM6.5i Angola.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage ao_relief.nc -Cpauline.cpt -R10/25/-19/-4 -JM6.5i -I+a15+ne0.75 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour ao1_relief.nc -R -J -C500 -A1000+f7p,26,darkbrown -Wthinnest,darkbrown -O -K >> $ps
# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps
# add lakes
#gmt pscoast -R -J -Ia/thinner,blue -Na -Sroyalblue1 -W2/thin,blue,0.1p -Df -O -K >> $ps

# 3: Undo the clipping
gmt psclip -C -O -K >> $ps
#-------------------------<
    
# Add color legend
gmt psscale -Dg8/-19+w16.5c/0.15i+v+o0.3/0i+ml+e -R -J -Cpauline.cpt \
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
    -B+t"Topographic map of Angola" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=9p,0,black \
    --FONT_ANNOT_PRIMARY=9p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx14.0c/-1.3c+c10+w400k+l"Mercator projection. Scale (km)"+f \
    -UBL/0p/-30p -O -K >> $ps

# Study area
# Rotated rectangle. kwargs: -Sjdirection/width/height, coords
gmt psxy -R -J -Sj-13/1.5/1.5 -W1.7p,yellow -O -K << EOF >> $ps
19.00 -12.90
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,0,yellow1+jLB >> $ps << EOF
18.6 -12.80 Study
18.6 -13.20 Area
EOF

# Texts
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,29,black+jLB >> $ps << EOF
17.5 -6.5 D. R. C O N G O
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,29,gray25+jLB >> $ps << EOF
22.5 -15.5 Z A M B I A
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,29,gray25+jLB >> $ps << EOF
22.0 -18.6 BOTSWANA
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,29,gray25+jLB >> $ps << EOF
16.5 -18.5 N A M I B I A
EOF
# rivers
gmt pstext -R -J -N -O -K \
-F+f14p,23,white+jLB >> $ps << EOF
10.3 -11.8 A T L A N T I C
10.3 -12.3 O C E A N
EOF
# cities
gmt pstext -R -J -N -O -K \
-F+f16p,0,black+jLB >> $ps << EOF
13.38 -8.83 Luanda
EOF
gmt psxy -R -J -Sc -W0.5p -Gred -O -K << EOF >> $ps
13.23 -8.83 0.25c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,0,lightgoldenrodyellow+jLB >> $ps << EOF
13.7 -14.88 Lubango
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
13.5 -14.92 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,0,lightgoldenrodyellow+jLB >> $ps << EOF
15.73 -13.17 Huambo
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
15.73 -12.77 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,0,black+jLB -Gwhite@70 >> $ps << EOF
13.41 -12.45 Benguela
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
13.41 -12.55 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,0,black+jLB -Gwhite@70 >> $ps << EOF
16.35 -9.43 Malanje
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
16.35 -9.53 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,0,black+jLB >> $ps << EOF
20.50 -9.75 Saurimo
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
20.40 -9.65 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,0,lightgoldenrodyellow+jLB >> $ps << EOF
16.93 -12.28 Cuíto
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
16.93 -12.38 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,0,black+jLB -Gwhite@70 >> $ps << EOF
15.05 -7.52 Uíge
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
15.05 -7.62 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,0,lightgoldenrodyellow+jLB >> $ps << EOF
17.68 -14.55 Menongue
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
17.68 -14.65 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,0,black+jLB >> $ps << EOF
20.00 -11.79 Luena
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
19.91 -11.79 0.20c
EOF
# rivers
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,23,blue+jLB+a-56 >> $ps << EOF
18.05 -16.70 Okavango
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,23,blue+jLB+a-40 >> $ps << EOF
19.80 -17.30 Cuito
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,23,blue+jLB+a38 >> $ps << EOF
22.70 -11.80 Zambezi
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,23,blue+jLB+a-59 >> $ps << EOF
17.85 -8.35 Cuango
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,23,blue+jLB >> $ps << EOF
15.00 -9.70 Cuanza
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,23,blue+jLB+a44 >> $ps << EOF
14.40 -17.10 Cunene
EOF
# insert map
# Countries codes: ISO 3166-1 alpha-2. Continent codes AF (Africa), AN (Antarctica), AS (Asia), EU (Europe), OC (Oceania), NA (North America), or SA (South America). -EEU+ggrey
gmt psbasemap -R -J -O -K -DjTR+w3.2c+o-0.2c/-0.2c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thinnest,lightgray --MAP_FRAME_PEN=thick,white -Rg -JG17.0/12.0S/$w -Da -Glightgoldenrod1 -A5000 -Bga -Wfaint -EAO+gred -Sroyalblue1 -O -K -X$x0 -Y$y0 >> $ps
#gmt pscoast -Rg -JG12/5N/$w -Da -Gbrown -A5000 -Bg -Wfaint -ECM+gbisque -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx7.0/-1.8+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y10.2c -N -O \
    -F+f11p,0,black+jLB >> $ps << EOF
2.5 11.0 Digital elevation data: SRTM/GEBCO, 15 arc sec resolution grid
EOF

# Convert to image file using GhostScript
gmt psconvert Topo_AO.ps -A0.5c -E720 -Tj -Z
