#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: Mali)
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert
# http://soliton.vm.bytemark.co.uk/pub/cpt-city/esri/hillshade/tn/illumination.png.index.html

exec bash

# Extract a subset of ETOPO1m for the study area
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R17.5/21/-34.3/-31.7 -Gza1_relief_CT.nc
gmt grdcut GEBCO_2023.nc -R17.5/21/-34.3/-31.7 -Gza_relief_CT.nc
gmt grdinfo -M za_relief_CT.nc
# Minimum=-3206.000, Maximum=2186.000

# Make color palette
#gmt makecpt -Cgeo -V -T-4430/2533 > pauline.cpt
#gmt makecpt -Cturbo -V -T-4430/2533 > pauline.cpt
#gmt makecpt -Cetopo1 -V -T-4430/2533  > pauline.cpt
#gmt makecpt -Cterra -V -T-4430/2533 > pauline.cpt
gmt makecpt -Cearth -V -T-3206/2186 > pauline.cpt
#gmt makecpt -Cdem1 -V -T-4430/2533 > pauline.cpt

# gmt makecpt -Cafrikakarte -V -T-3395/1000 > pauline.cpt
# gmt makecpt -Cillumination -V -T-5000/500 -Ic > pauline.cpt
# gmt makecpt -Cwiki-1.02.cpt -V -T-3000/500 > pauline.cpt
# elevation etopo1 world elevation dem1 dem2 dem3 globe geo srtm turbo terra earth

#####################################################################
# create mask of vector layer from the DCW of country's polygon
#gmt pscoast -R17.5/21/-34.3/-31.7 -JM6.5i -Dh -M -EZA > SouthAfrica.txt
#####################################################################

ps=Topo_ZA_CT.ps
# Make background transparent image
gmt grdimage za_relief_CT.nc -Cpauline.cpt -R17.5/21/-34.3/-31.7 -JM6.5i -I+a15+ne0.75 -Xc -P -K > $ps

# Add isolines
gmt grdcontour za1_relief_CT.nc -R -J -C250 -A1000+f7p,26,darkbrown -Wthinner,darkbrown -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps
# Add lakes
gmt pscoast -R -J -Ia/thinner,blue -Na -Sroyalblue1 -W2/thin,blue,0.1p -Df -O -K >> $ps
    
# Add color legend -R17.5/21/-34.3/-31.7
gmt psscale -Dg17.0/-34.3+w14.0c/0.15i+v+o0.3/0i+ml+e -R -J -Cpauline.cpt \
    --FONT_LABEL=9p,0,black \
    --FONT_ANNOT_PRIMARY=9p,0,black \
    --FONT_TITLE=8p,0,black \
    -Bg1000f100a1000+l"Colormap: 'earth' - colors for global bathymetry/topography relief [R=-3206/2186, H, C=RGB]" \
    -I0.2 -By+l"m" -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=wEsN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    --MAP_FRAME_PEN=dimgray \
    --MAP_FRAME_WIDTH=0.1c \
    --MAP_TITLE_OFFSET=0.7c \
    --FONT_ANNOT_PRIMARY=10p,0,black \
    --FONT_LABEL=11p,25,black \
    --FONT_TITLE=12p,0,black \
        -Bpxg2f0.5a0.5 -Bpyg2f0.5a0.5 -Bsxg2 -Bsyg1 \
    -B+t"Topographic map of Saldanna-Cape Town region, South Africa" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=11p,0,black \
    --FONT_ANNOT_PRIMARY=12p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx14.5c/-1.3c+c10+w100k+l"Mercator projection. Scale (km)"+f \
    -UBL/0p/-30p -O -K >> $ps

# Study area
# Rotated rectangle. kwargs: -Sjdirection/width/height, coords

# Texts
gmt pstext -R -J -N -O -K \
-F+f14p,23,white+jLB >> $ps << EOF
15.4 -35.5 A T L A N T I C
15.4 -36.0 O C E A N
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f15p,23,white+jLB >> $ps << EOF
17.66 -32.40 Saint Helena
17.80 -32.55 Bay
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f15p,23,white+jLB >> $ps << EOF
18.52 -34.18 False
18.52 -34.28 Bay
EOF
gmt pstext -R -J -N -O -K \
-F+f17p,23,azure1+jLB >> $ps << EOF
17.60 -33.60 ATLANTIC
17.60 -33.80 OCEAN
EOF
gmt pstext -R -J -N -O -K \
-F+f15p,0,white+jLB >> $ps << EOF
18.07 -33.87 Cape
18.07 -33.97 Town
EOF
gmt psxy -R -J -Sc -W0.5p -Gred -O -K << EOF >> $ps
18.42 -33.93 0.40c
EOF
gmt pstext -R -J -N -O -K \
-F+f14p,0,black+jLB -Gwhite@60 >> $ps << EOF
18.00 -33.05 Saldanha
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
17.94 -32.99 0.35c
EOF
gmt pstext -R -J -N -O -K \
-F+f14p,0,black+jLB -Gwhite@30 >> $ps << EOF
18.92 -34.04 Stellenbosch
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
18.86 -33.94 0.35c
EOF
gmt pstext -R -J -N -O -K \
-F+f14p,23,white+jLB+a-50 >> $ps << EOF
20.05 -31.9 R O G G E F E L D  M T S
EOF
gmt pstext -R -J -N -O -K \
-F+f14p,23,SIENNA4+jLB >> $ps << EOF
19.52 -32.35 Tankwa Karoo
19.52 -32.45 National Park
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,23,white+jLB -GGOLDENROD4@50 >> $ps << EOF
19.20 -33.10 Koue Bokkeveld
19.40 -33.20 Mts
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,23,white+jLB -GGOLDENROD4@50 >> $ps << EOF
19.08 -32.33 Cederberg
19.18 -32.40 Mts
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,23,SEAGREEN4+jLB >> $ps << EOF
18.10 -33.12 West Coast
18.10 -33.20 National Park
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,23,white+jLB -GGOLDENROD4@70 >> $ps << EOF
19.00 -33.82 Haweqwa
19.10 -33.92 Mts
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,23,white+jLB >> $ps << EOF
19.5 -33.42 Hex River
19.5 -33.52 Mts
EOF
#
gmt pstext -R -J -N -O -K \
-F+f12p,23,MEDIUMBLUE+jLB+a-43 >> $ps << EOF
18.15 -32.75 Berg River
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,MEDIUMBLUE+jLB+a-68 >> $ps << EOF
18.85 -33.22 Berg
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,MEDIUMBLUE+jLB+a-30 -GDARKOLIVEGREEN2@50 >> $ps << EOF
19.40 -33.65 Breede River
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,MEDIUMBLUE+jLB+a-73 -GPALEGREEN@50 >> $ps << EOF
18.85 -32.40 Olifants River
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,MEDIUMBLUE+jLB+a-15 -GPALEGREEN@50 >> $ps << EOF
18.90 -31.85 Doring
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,MEDIUMBLUE+jLB+a-60 >> $ps << EOF
19.62 -32.60 Doring
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,MEDIUMBLUE+jLB+a-10 -GPALEGREEN@70 >> $ps << EOF
20.40 -33.60 Touws
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,MEDIUMBLUE+jLB+a80 -GPALEGREEN@70 >> $ps << EOF
20.83 -33.20 Groot
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,LIGHTSKYBLUE1+jLB+a-74 >> $ps << EOF
20.37 -31.74 Vis River
EOF
# Add GMT logo
gmt logo -Dx7.0/-1.8+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y8.1c -N -O \
    -F+f11p,0,black+jLB >> $ps << EOF
2.5 11.0 Digital elevation data: SRTM/GEBCO, 15 arc sec resolution grid
EOF

# Convert to image file using GhostScript
gmt psconvert Topo_ZA_CT.ps -A0.5c -E720 -Tj -Z
