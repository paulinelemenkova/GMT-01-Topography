#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: Namibia)
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert
# http://soliton.vm.bytemark.co.uk/pub/cpt-city/esri/hillshade/tn/illumination.png.index.html

exec bash

# Extract a subset of ETOPO1m for the study area
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R10/26/-30/-16 -Gna1_relief.nc
gmt grdcut GEBCO_2023.nc -R10/26/-30/-16 -Gna_relief.nc
gmt grdinfo -M na_relief.nc
# Minimum=-5033.000, Maximum=2477.000, Mean=458.513, StdDev=1364.345

# Make color palette
#gmt makecpt -Cgeo -V -T-4430/2533 > pauline.cpt
#gmt makecpt -Cturbo -V -T-4430/2533 > pauline.cpt
#gmt makecpt -Cetopo1 -V -T-4430/2533  > pauline.cpt
#gmt makecpt -Cterra -V -T-4430/2533 > pauline.cpt
gmt makecpt -Cearth -V -T-5033/2477 > pauline.cpt
#gmt makecpt -Cdem1 -V -T-4430/2533 > pauline.cpt

# gmt makecpt -Cafrikakarte -V -T-3395/1000 > pauline.cpt
# gmt makecpt -Cillumination -V -T-5000/500 -Ic > pauline.cpt
# gmt makecpt -Cwiki-1.02.cpt -V -T-3000/500 > pauline.cpt
# elevation etopo1 world elevation dem1 dem2 dem3 globe geo srtm turbo terra earth

#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R10/26/-30/-16 -JM6.5i -Dh -M -ENA > Namibia.txt
#####################################################################

ps=Topo_NA.ps
# Make background transparent image
gmt grdimage na_relief.nc -Cpauline.cpt -R10/26/-30/-16 -JM6.5i -I+a15+ne0.75 -t40 -Xc -P -K > $ps

# Add isolines
gmt grdcontour na1_relief.nc -R -J -C500 -A1000+f7p,26,darkbrown -Wthinner,darkbrown -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thickest,tomato -W0.1p -Df -O -K >> $ps
# Add lakes
# gmt pscoast -R -J -Ia/thinner,blue -Na -Sroyalblue1 -W2/thin,blue,0.1p -Df -O -K >> $ps
    
#------------------------->
# CLIPPING
# 1. Start: clip the map by mask to only include country
gmt psclip -R10/26/-30/-16 -JM6.5i Namibia.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage na_relief.nc -Cpauline.cpt -R10/26/-30/-16 -JM6.5i -I+a15+ne0.75 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour na1_relief.nc -R -J -C500 -A1000+f7p,26,darkbrown -Wthinnest,darkbrown -O -K >> $ps
# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thickest,tomato -W0.1p -Df -O -K >> $ps
# add lakes
gmt pscoast -R -J -Ia/thinner,blue -Na -Sroyalblue1 -W2/thin,blue,0.1p -Df -O -K >> $ps

# 3: Undo the clipping
gmt psclip -C -O -K >> $ps
#-------------------------<
    
# Add color legend
gmt psscale -Dg7.8/-30+w15.3c/0.15i+v+o0.3/0i+ml+e -R -J -Cpauline.cpt \
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
    -B+t"Topographic map of Namibia" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=9p,0,black \
    --FONT_ANNOT_PRIMARY=9p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx14.0c/-1.0c+c10+w400k+l"Mercator projection. Scale (km)"+f \
    -UBL/0p/-30p -O -K >> $ps

# Study area
# Rotated rectangle. kwargs: -Sjdirection/width/height, coords
gmt psxy -R -J -Sj-13/2.0/2.0 -W2.0p,cyan1 -O -K << EOF >> $ps
16.30 -18.70
EOF

# Texts
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,0,ivory+jLB >> $ps << EOF
16.4 -16.8 A N G O L A
EOF
gmt pstext -R -J -N -O -K \
-F+f14p,0,ivory+jLB >> $ps << EOF
23.0 -16.8 Z A M B I A
EOF
gmt pstext -R -J -N -O -K \
-F+f14p,0,ivory+jLB >> $ps << EOF
20.3 -23.7 B O T S W A N A
EOF
gmt pstext -R -J -N -O -K \
-F+f14p,0,ivory+jLB >> $ps << EOF
20.50 -27.6 S O U T H   A F R I C A
EOF
gmt pstext -R -J -N -O -K \
-F+f14p,23,white+jLB >> $ps << EOF
10.2 -25.5 A T L A N T I C
10.2 -26.5 O C E A N
EOF
# rivers
gmt pstext -R -J -N -O -K \
-F+f13p,23,blue+jLB+a43 >> $ps << EOF
17.60 -21.3 Omatako
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,23,midnightblue+jLB+a20 >> $ps << EOF
16.05 -18.9 Etosha
16.25 -19.2 Pan
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,23,blue+jLB+a-5 >> $ps << EOF
18.80 -17.7 Okavango
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,blue+jLB+a-40 >> $ps << EOF
19.10 -24.0 Nossob
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,blue+jLB+a75 -Gpalegoldenrod@40 >> $ps << EOF
18.05 -27.4 Fish
EOF
# geography
gmt pstext -R -J -N -O -K \
-F+f14p,2,darkred+jLB >> $ps << EOF
20.3 -24.4 K A L A H A R I
20.3 -24.9 D E S E R T
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,darkred+jLB+a-60 -Gpalegoldenrod@40 >> $ps << EOF
13.65 -20.90 N A M I B
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,darkred+jLB+a-80 -Gpalegoldenrod@40 >> $ps << EOF
14.80 -23.70 D E S E R T
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,2,lemonchiffon+jLB+a10 >> $ps << EOF
16.60 -19.70 Otavi Mts.
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,darkolivegreen+jLB+a-60 -Ghoneydew@40 >> $ps << EOF
11.95 -17.80 Skeleton Coast Park
EOF
# cities
gmt pstext -R -J -N -O -K \
-F+f13p,0,mintcream+jLB >> $ps << EOF
19.86 -18.32 Rundu
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
19.76 -17.92 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,0,mintcream+jLB >> $ps << EOF
17.02 -21.68 Okahandja
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
16.92 -21.98 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,0,mintcream+jLB >> $ps << EOF
16.05 -18.22 Ondangwa
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
15.95 -17.92 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,0,mintcream+jLB >> $ps << EOF
16.10 -20.15 Otjiwarongo
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
16.65 -20.45 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,0,mintcream+jLB >> $ps << EOF
17.18 -23.72 Rehoboth
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
17.08 -23.32 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,0,mintcream+jLB >> $ps << EOF
15.78 -17.68 Oshakati
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
15.68 -17.78 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,0,mintcream+jLB >> $ps << EOF
14.63 -22.38 Swakopmund
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
14.53 -22.68 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,0,mintcream+jLB -Ggoldenrod@50 >> $ps << EOF
14.6 -22.95 Walvis Bay
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
14.5 -22.95 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f14p,1,mintcream+jLB >> $ps << EOF
17.23 -22.66 Windhoek
EOF
gmt psxy -R -J -Sa -W0.5p -Gred -O -K << EOF >> $ps
17.08 -22.56 0.45c
EOF

# insert map
# Countries codes: ISO 3166-1 alpha-2. Continent codes AF (Africa), AN (Antarctica), AS (Asia), EU (Europe), OC (Oceania), NA (North America), or SA (South America). -EEU+ggrey
gmt psbasemap -R -J -O -K -DjBL+w3.5c+o-0.2c/-0.2c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thinnest,lightgray --MAP_FRAME_PEN=thick,white -Rg -JG17.0/23.0S/$w -Da -Glightgoldenrod1 -A5000 -Bga -Wfaint -ENA+gred -Sroyalblue1 -O -K -X$x0 -Y$y0 >> $ps
#gmt pscoast -Rg -JG12/5N/$w -Da -Gbrown -A5000 -Bg -Wfaint -ECM+gbisque -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx7.0/-1.5+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y9.3c -N -O \
    -F+f11p,0,black+jLB >> $ps << EOF
2.5 11.0 Digital elevation data: SRTM/GEBCO, 15 arc sec resolution grid
EOF

# Convert to image file using GhostScript
gmt psconvert Topo_NA.ps -A0.5c -E720 -Tj -Z
