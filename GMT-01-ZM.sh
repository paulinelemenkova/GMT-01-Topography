#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: Zambia)
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert
# http://soliton.vm.bytemark.co.uk/pub/cpt-city/jm/tv/index.html

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
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R21/34/-19/-8 -Gzm_relief.nc
#gmt grdcut GEBCO_2019.nc -R21/34/-18/-8 -Gzm_relief.nc
gdalinfo -stats zm_relief.nc
#  Minimum=106.000, Maximum=2846.000, Mean=1073.898, StdDev=268.713

#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R21/34/-19/-8 -JM6.5i -Dh -M -EZM > Zambia.txt
#gmt pscoast -Dh -M -ELB > Malawi.txt
#####################################################################

# Make color palette
#gmt makecpt -Cafrikakarte-topo -V -T443/5110 > pauline.cpt
gmt makecpt -Ctv-a -V -T106/2846 > pauline.cpt
#gmt makecpt -Csd-a -V -T106/2846 > pauline.cpt
#gmt makecpt -Cwiki-1.02 -V -T443/5110 > pauline.cpt
# elevation etopo1 world elevation dem1 dem2 dem3 globe geo srtm turbo terra earth relief costa-rica

ps=Topo_ZM.ps
# Make background transparent image
gmt grdimage zm_relief.nc -Cpauline.cpt -R21/34/-19/-8 -JM6.5i -I+a15+ne0.75 -t50 -Xc -P -K > $ps
    
# Add isolines
gmt grdcontour zm_relief.nc -R -J -C1000 -A1000+f7p,26,darkbrown -Wthinner,darkbrown -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,red -W0.1p -Df -O -K >> $ps
    
#####################################################################
# CLIPPING
# 1. Start: clip the map by mask to only include country
#gmt psclip -JM -R Malawi.txt -O -K >> $ps

gmt psclip -R21/34/-19/-8 -JM6.5i Zambia.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage zm_relief.nc -Cpauline.cpt -R21/34/-19/-8 -JM6.5i -I+a15+ne0.75 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour zm_relief.nc -R -J -C250 -Wthinnest,darkbrown -O -K >> $ps
# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps
#gmt pscoast -R -J \
    -Ia/thinner,blue -Na -W0.1p -Df -O -K >> $ps

# 3: Undo the clipping
gmt psclip -C -O -K >> $ps
#####################################################################
    
# Add color legend
gmt psscale -Dg21.0/-20.0+w16.5c/0.15i+h+o0.3/0i+ml+e -R -J -Cpauline.cpt \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_TITLE=6p,0,black \
    -Bg500f25a250+l"Colormap: 'tv-a' scheme by Jim Mossman [R=106/2846, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=WEsN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    -Bpxg1f0.5a1 -Bpyg1f0.5a1 -Bsxg1 -Bsyg1 \
    --MAP_TITLE_OFFSET=0.8c \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --FONT_LABEL=8p,25,black \
    --FONT_TITLE=16p,19,black \
    -B+t"Topographic map of Zambia" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx14.5c/-2.5c+c10+w200k+l"Mercator projection. Scale (km)"+f \
    -UBL/0p/-70p -O -K >> $ps

# Texts
gmt pstext -R -J -N -O -K \
-F+f13p,0,black+jLB -Gwhite@60 >> $ps << EOF
28.38 -15.42 Lusaka
EOF
gmt psxy -R -J -Ss -W0.5p -Ggreen1 -O -K << EOF >> $ps
28.28 -15.42 0.30c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@50 >> $ps << EOF
27.40 -12.90 Kitwe
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
28.20 -12.82 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@50 >> $ps << EOF
28.30 -12.86 Ndola
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
28.63 -12.96 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@50 >> $ps << EOF
27.50 -14.43 Kabwe
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
28.45 -14.43 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@50 >> $ps << EOF
26.7 -12.50 Chingola
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
27.85 -12.53 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@50 >> $ps << EOF
28.35 -12.56 Mufulira
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
28.24 -12.54 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@50 >> $ps << EOF
25.50 -17.70 Livingstone
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
25.86 -17.85 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@50 >> $ps << EOF
27.60 -13.35 Luanshya
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
28.4 -13.13 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@50 >> $ps << EOF
31.65 -13.60 Chipata
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
32.64 -13.64 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@50 >> $ps << EOF
31.30 -10.21 Kasama
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
31.18 -10.21 0.20c
EOF
#
# countries
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,19,black+jLB -Gwhite@60 >> $ps << EOF
21.3 -12.0 A  N  G  O  L  A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,19,black+jLB -Gwhite@60 >> $ps << EOF
26.0 -10.5 C  O  N  G  O
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,19,black+jLB -Gwhite@60 >> $ps << EOF
31.5 -8.5 T A N Z A N I A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,19,black+jLB -Gwhite@60 >> $ps << EOF
30.3 -15.5 M O Z A M B I Q U E
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,19,black+jLB -Gwhite@60 >> $ps << EOF
30.0 -17.5 Z I M B A B W E
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,19,black+jLB -Gwhite@60 >> $ps << EOF
22.5 -18.8 B O T S W A N A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,19,black+jLB+a-350 -Gwhite@60 >> $ps << EOF
21.5 -18.25 N A M I B I A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,19,black+jLB+a-270 -Gwhite@60 >> $ps << EOF
33.85 -13.5 M A L A W I
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f17p,19,black+jLB -Gwhite@80 >> $ps << EOF
26.6 -14.1 Z  A  M  B  I  A
EOF
#rivers
gmt pstext -R -J -N -O -K \
-F+f10p,23,blue2+jLB+a-45 >> $ps << EOF
23.4 -16.3 Zambezi
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,23,blue2+jLB >> $ps << EOF
24.2 -13.8 Dongwe
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,23,blue2+jLB >> $ps << EOF
25.3 -14.0 Busanga
25.3 -14.3 Swamp
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,23,blue2+jLB >> $ps << EOF
27.1 -14.7 Lukanga
27.1 -14.9 Swamp
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,23,blue2+jLB >> $ps << EOF
30.1 -11.6 Bangweulu
30.1 -11.9 Swamp
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,23,blue2+jLB >> $ps << EOF
29.5 -11.0 Lake
29.5 -11.3 Bangweulu
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,23,blue2+jLB+a-320 >> $ps << EOF
28.6 -9.3 Lake Mweru
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,23,blue2+jLB+a-300 >> $ps << EOF
31.8 -12.9 Luangwa
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,23,blue2+jLB+a-315 >> $ps << EOF
30.7 -11.2 Chambeshi
EOF
#Mts
gmt pstext -R -J -N -O -K \
-F+f13p,20,darkbrown+jLB+a-300 -Gwhite@70 >> $ps << EOF
30.3 -13.6 Muchinga Mountains
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,23,blue2+jLB+a-330 -Gwhite@70 >> $ps << EOF
27.7 -17.0 Lake Kariba
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,23,blue2+jLB+a-312 >> $ps << EOF
24.0 -13.7 Kabompo
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,23,blue2+jLB+a-280 >> $ps << EOF
26.45 -12.8 Lunga
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,23,blue2+jLB+a-350 >> $ps << EOF
26.4 -15.6 Kafue
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,23,blue2+jLB+a-350 >> $ps << EOF
26.6 -14.4 Kafue
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,23,blue2+jLB+a-340 >> $ps << EOF
23.2 -14.8 Luena Flats
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,23,blue2+jLB+a-35 >> $ps << EOF
22.05 -13.4 Lungwebungu
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,23,blue2+jLB+a-290 >> $ps << EOF
26.3 -17.5 Kalomo
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,23,blue2+jLB+a-20 -Gwhite@70 >> $ps << EOF
29.4 -9.5 Kalungwishi
EOF

# insert map
# Countries codes: ISO 3166-1 alpha-2. Continent codes AF (Africa), AN (Antarctica), AS (Asia), EU (Europe), OC (Oceania), NA (North America), or SA (South America). -EEU+ggrey
gmt psbasemap -R -J -O -K -DjTL+w3.2c+o-0.2c/-0.2c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thinnest,grey -Rg -JG28.0/-2.0S/$w -Da -Glightgoldenrod1 -A5000 -Bga -Wfaint -EZM+gred -Sdodgerblue -O -K -X$x0 -Y$y0 >> $ps
#gmt pscoast -Rg -JG12/5N/$w -Da -Gbrown -A5000 -Bg -Wfaint -ECM+gbisque -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx7.0/-3.1+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y9.8c -N -O \
    -F+f10p,0,black+jLB >> $ps << EOF
2.0 8.0 Digital elevation data: GEBCO/SRTM, 15 arc sec (ca. 450 m) resolution grid
EOF

# Convert to image file using GhostScript
gmt psconvert Topo_ZM.ps -A0.5c -E720 -Tj -Z
