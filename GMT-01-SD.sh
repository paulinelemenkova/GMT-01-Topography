#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: Sudan)
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
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R20/40/8/23 -Gsd1_relief.nc
gmt grdcut GEBCO_2019.nc -R20/40/8/23 -Gsd_relief.nc
gdalinfo -stats sd1_relief.nc
# actual_range={-2756,4326}

# Make color palette
gmt makecpt -Cgeo -V -T-2756/3042 > pauline.cpt
# elevation etopo1 world elevation dem1 dem2 dem3 globe geo srtm turbo terra earth

#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R20/40/8/23 -JT30/6.5i -Dh -M -ESD > Sudan.txt
#####################################################################

ps=Topo_SD.ps
# Make background transparent image

gmt grdimage sd1_relief.nc -Cpauline.cpt -R20/40/8/23 -JT30/6.5i -I+a15+ne0.75 -t40 -Xc -P -K > $ps

# Add isolines
gmt grdcontour sd1_relief.nc -R -J -C1000 -A1000+f7p,26,darkbrown -Wthinner,darkbrown -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps
    
#####################################################################
# CLIPPING
# 1. Start: clip the map by mask to only include country

gmt psclip -R20/40/8/23 -JT30/6.5i Sudan.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage sd1_relief.nc -Cpauline.cpt -R20/40/8/23 -JT30/6.5i -I+a15+ne0.75 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour sd1_relief.nc -R -J -C500 -Wthinnest,darkbrown -O -K >> $ps
# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps
#gmt pscoast -R -J \
    -Ia/thinner,blue -Na -W0.1p -Df -O -K >> $ps

# 3: Undo the clipping
gmt psclip -C -O -K >> $ps
#####################################################################
    
# Add color legend
gmt psscale -Dg19.5/6.5+w16.5c/0.15i+h+o0.3/0i+ml+e -R -J -Cpauline.cpt \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_TITLE=6p,0,black \
    -Bg500f100a500+l"Colormap: 'earth' Colors for global topography relief [R=-2756/3042, H, C=RGB]" \
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
    -B+t"Topographic map of Sudan" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=9p,0,black \
    --FONT_ANNOT_PRIMARY=9p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx14.0c/-2.4c+c10+w500k+l"Transverse Mercator prj; central meridian=30\232E. Scale (km)"+f \
    -UBL/0p/-70p -O -K >> $ps

# Cities -R20/40/8/23
gmt pstext -R -J -N -O -K \
-F+f11p,21,ivory1+jLB >> $ps << EOF
30.40 15.70 Omdurman
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
32.48 15.65 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,21,ivory1+jLB >> $ps << EOF
25.03 12.05 Nyala
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
24.88 12.05 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,21,blue1+jLB >> $ps << EOF
37.35 19.70 Port
37.35 19.60 Sudan
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
37.22 19.62 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,21,ivory1+jLB >> $ps << EOF
30.37 13.10 El-Obeid
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
30.22 13.18 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,21,ivory1+jLB >> $ps << EOF
35.5 15.55 Kassala
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
36.4 15.45 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,21,ivory1+jLB >> $ps << EOF
33.57 14.45 Wad Madani
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
33.52 14.4 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,21,ivory1+jLB >> $ps << EOF
34.08 13.90 El-Gadarif
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
35.38 14.03 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,21,ivory1+jLB >> $ps << EOF
25.50 13.45 Al-Fashir
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
25.35 13.62 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,21,ivory1+jLB >> $ps << EOF
34.10 17.68 Atbara
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
33.97 17.68 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f15p,1,yellow+jLB >> $ps << EOF
32.75 15.45 Khartoum
EOF
gmt psxy -R -J -Sa -W0.5p -Gred -O -K << EOF >> $ps
32.55 15.5 0.35c
EOF
#------ countries
gmt pstext -R -J -N -O -K \
-F+jTL+f18p,19,black+jLB -Gwhite@80 >> $ps << EOF
27.0 16.5 S  U  D  A  N
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,19,gray25+jLB >> $ps << EOF
27.5 22.2 E  G  Y  P  T
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,19,gray25+jLB >> $ps << EOF
21.0 22.1 L I B Y A
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,19,gray25+jLB >> $ps << EOF
20.5 16.3 C H A D
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,19,gray25+jLB >> $ps << EOF
21.1 9.2 CENTRAL
21.1 8.7 AFRICAN
21.1 8.2 REPUBLIC
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,19,gray25+jLB >> $ps << EOF
26.5 8.5 S O U T H   S U D A N
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,19,gray25+jLB -Gwhite@50 >> $ps << EOF
37.0 12.5 ETHIOPIA
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,19,gray25+jLB -Gwhite@50 >> $ps << EOF
37.0 15.5 ERITREA
EOF
# water
gmt pstext -R -J -N -O -K \
-F+f12p,23,blue1+jLB+a-65 >> $ps << EOF
30.5 19.0 Nile
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,blue2+jLB+a-65 >> $ps << EOF
33.5 15.3 Blue Nile
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,blue2+jLB+a-65 >> $ps << EOF
32.3 14.6 White Nile
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,blue2+jLB -Gwhite@60 >> $ps << EOF
37.2 21.5 Red Sea
EOF
# GEOGRAPHY
gmt pstext -R -J -N -O -K \
-F+f13p,20,lightgoldenrod2+jLB >> $ps << EOF
24.5 19.2 LIBYAN
24.5 18.5 DESERT
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,20,lightgoldenrod1+jLB >> $ps << EOF
31.8 21.2 N U B I A N
31.8 20.6 D E S E R T
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,0,floralwhite+jLB+a45 >> $ps << EOF
23.7 12.5 Marra Mts.
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,0,floralwhite+jLB >> $ps << EOF
29.5 11.5 Nuba Mts.
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,22,white+jLB+a-75 >> $ps << EOF
36.2 21.5 Red Sea Hills
EOF

# insert map
# Countries codes: ISO 3166-1 alpha-2. Continent codes AF (Africa), AN (Antarctica), AS (Asia), EU (Europe), OC (Oceania), NA (North America), or SA (South America). -EEU+ggrey
gmt psbasemap -R -J -O -K -DjBR+w3.5c+o-0.2c/-0.2c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thin,grey -Rg -JG28.0/8.0N/$w -Da -Glightgoldenrod1 -A5000 -Bga -Wfaint -ESD+gred -Sdodgerblue -O -K -X$x0 -Y$y0 >> $ps
#gmt pscoast -Rg -JG12/5N/$w -Da -Gbrown -A5000 -Bg -Wfaint -ECM+gbisque -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx7.0/-3.1+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y6.6c -N -O \
    -F+f10p,0,black+jLB >> $ps << EOF
3.0 10.4 Digital elevation data: SRTM/GEBCO, 15 arc sec resolution grid
EOF

# Convert to image file using GhostScript
gmt psconvert Topo_SD.ps -A0.5c -E720 -Tj -Z
