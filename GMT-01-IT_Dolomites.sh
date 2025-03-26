#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: Benin)
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert

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

exec bash

# Extract a subset of ETOPO1m for the study area
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R6/20/36/48 -Git1_relief.nc
gmt grdcut GEBCO_2023.nc -R6/20/36/48 -Git_relief.nc
gmt grdinfo -M it_relief.nc
# gdalinfo -stats it_relief.nc

# Make color palette
#gmt makecpt -Cgeo -V -T-4151/4655 > pauline.cpt
gmt makecpt -Cetopo1 -V -T-4151/4655 > pauline.cpt
# elevation etopo1 world elevation dem1 dem2 dem3 globe geo srtm turbo terra earth

#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R6/20/36/48 -JM6.5i -Dh -M -EIT > Italy.txt
#####################################################################

ps=Topo_IT.ps
# Make background transparent image
gmt grdimage it_relief.nc -Cpauline.cpt -R6/20/36/48 -JM6.5i -I+a15+ne0.75 -t40 -Xc -P -K > $ps
    
# Add isolines
gmt grdcontour it1_relief.nc -R -J -C1000 -A1000+f6p,26,darkbrown -Wthinnest,darkbrown -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thick,dimgray -W0.1p -Df -O -K >> $ps
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps
    
#####################################################################
# CLIPPING
# 1. Start: clip the map by mask to only include country
gmt psclip -R6/20/36/48 -JM6.5i Italy.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage it_relief.nc -Cpauline.cpt -R6/20/36/48 -JM6.5i -I+a15+ne0.75 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour it1_relief.nc -R -J -C1000 -Wthinnest,darkbrown -O -K >> $ps
# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps
# Add lakes
gmt pscoast -R -J -Ia/thinner,blue -Na -Sroyalblue1 -W2/thin,blue,0.1p -Df -O -K >> $ps

# 3: Undo the clipping
gmt psclip -C -O -K >> $ps
#####################################################################
    
# Add color legend
gmt psscale -Dg4/36+w19.0c/0.15i+v+o0.3/0i+ml+e -R -J -Cpauline.cpt \
    --FONT_LABEL=10p,0,black \
    --FONT_ANNOT_PRIMARY=10p,0,black \
    --FONT_TITLE=10p,0,black \
    -Bg500f50a500+l"Colormap: 'geo' Colors for global bathymetry/topography relief [R=-4151/4655, H, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=wESN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    --MAP_TITLE_OFFSET=0.7c \
    --FONT_ANNOT_PRIMARY=9p,0,black \
    --FONT_LABEL=10p,25,black \
    --FONT_TITLE=12p,0,black \
        -Bpxg2f1a2 -Bpyg2f1a2 -Bsxg2 -Bsyg1 \
    -B+t"Location of the study area: coniferous forests of Dolomites in South Tyrol, north Italy" -O -K >> $ps
# Location of Foreste Casentinesi National Park on the topographic map of Italy: yellow square
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=12p,0,black \
    --FONT_ANNOT_PRIMARY=11p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx13.5c/-1.7c+c10+w400k+l"Mercator projection. Scale (km)"+f \
    -UBL/0p/-40p -O -K >> $ps
    
# Texts
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,26,blue+jLB+a-45 >> $ps << EOF
13.3 44.3 A d r i a t i c   S e a
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,26,white+jLB >> $ps << EOF
10.5 39.5 Tyrrhenian Sea
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,26,white+jLB -Groyalblue@90 >> $ps << EOF
8.3 43.6 Ligurian
8.5 43.3 Sea
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,26,white+jLB >> $ps << EOF
17.1 37.8 Ionian
17.3 37.4 Sea
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f13p,26,white+jLB >> $ps << EOF
6.1 38.1 Mediterranean
6.5 37.7 Sea
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,26,navy+jLB+a-33 -Gwhite@80 >> $ps << EOF
11.0 37.7 Straight of Sicily
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,blue+jLB >> $ps << EOF
12.5 45.1 Gulf of
12.55 44.8 Venice
EOF
# rivers
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,26,azure+jLB+a-10 >> $ps << EOF
10.2 45.1 Po
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,26,azure+jLB+a-48 >> $ps << EOF
8.4 45.5 Ticino
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,26,azure+jLB+a-55 >> $ps << EOF
11.9 42.6 Tiber
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,26,azure+jLB+a12 >> $ps << EOF
10.55 43.45 Arno
EOF
# cities
gmt pstext -R -J -N -O -K \
-F+f12p,22,azure2+jLB >> $ps << EOF
12.53 41.94 Rome
EOF
gmt psxy -R -J -Sa -W0.5p -Gred -O -K << EOF >> $ps
12.48 41.89 0.40c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,21,lightyellow+jLB >> $ps << EOF
9.24 45.51 Milan
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
9.19 45.47 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,21,lightyellow+jLB -Gseagreen@70 >> $ps << EOF
14.30 40.88 Naples
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
14.25 40.83 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,21,lightyellow+jLB >> $ps << EOF
7.72 45.15 Turin
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
7.68 45.08 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,21,black+jLB >> $ps << EOF
13.40 38.15 Palermo
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
13.35 38.11 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,21,lightyellow+jLB -Gsaddlebrown@70 >> $ps << EOF
9.0 44.45 Genoa
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
8.93 44.41 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,21,lightyellow+jLB >> $ps << EOF
10.70 44.60 Bologna
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
11.34 44.49 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,21,lightyellow+jLB -Gforestgreen@70 >> $ps << EOF
10.25 43.85 Florence
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
11.25 43.77 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,21,black+jLB >> $ps << EOF
16.90 41.17 Bari
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
16.86 41.12 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,21,lightyellow+jLB -Gsaddlebrown@70 >> $ps << EOF
14.14 37.55 Catania
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
15.09 37.50 0.20c
EOF
# countries
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,0,ivory+jLB -Gsaddlebrown@80 >> $ps << EOF
7.0 46.7 SWITZERLAND
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,0,ivory+jLB -Gsaddlebrown@80 >> $ps << EOF
11.8 47.2 A U S T R I A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,0,black+jLB -Gpapayawhip@70 >> $ps << EOF
13.9 45.9 SLOVENIA
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,0,black+jLB >> $ps << EOF
15.8 45.5 CROATIA
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,0,black+jLB -Gpapayawhip@80 >> $ps << EOF
17.0 44.1 BOSNIA AND
17.0 43.8 HERZEGOVINA
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f7p,0,black+jLB >> $ps << EOF
18.5 42.8 MONTENEGRO
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,0,ivory+jLB+a90 -Gsaddlebrown@70 >> $ps << EOF
6.5 44.2 F R A N C E
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,0,ivory+jLB -Gforestgreen@80 >> $ps << EOF
8.8 36.4 T U N I S I A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,0,ivory+jLB -Gforestgreen@80 >> $ps << EOF
6.2 36.4 A L G E R I A
EOF
# phys geogr
gmt pstext -R -J -N -O -K \
-F+f12p,23,lemonchiffon1+jLB+a-50-Gsaddlebrown@60 >> $ps << EOF
12.50 43.2 A P E N N I N E S
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,23,lemonchiffon1+jLB -Gsaddlebrown@60 >> $ps << EOF
10.80 46.2 Dolomites
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,23,lemonchiffon1+jLB -Gsaddlebrown@70 >> $ps << EOF
8.60 42.3 Corsica
8.60 42.1 (France)
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,21,lemonchiffon1+jLB -Gsaddlebrown@70 >> $ps << EOF
8.50 40.2 Sardinia
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,21,lemonchiffon1+jLB+a-27 -Gforestgreen@70 >> $ps << EOF
13.20 37.6 S i c i l y
EOF
# Study area
# Rotated rectangle. kwargs: -Sjdirection/width/height, coords
gmt psxy -R -J -Sj-0/2.0/1.5 -W1.5p,gold1 -O -K << EOF >> $ps
#11.43 46.59
11.43 46.20
EOF

# insert map
# Countries codes: ISO 3166-1 alpha-2. Continent codes AF (Africa), AN (Antarctica), AS (Asia), EU (Europe), OC (Oceania), NA (North America), or SA (South America). -EEU+ggrey
gmt psbasemap -R -J -O -K -DjTR+w3.5c+o-0.2c/-0.2c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thin,grey -Rg -JG12/40.0N/$w -Da -Glightgoldenrod1 -A5000 -Bga -Wfaint -EIT+gred -Sdodgerblue -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx6.5/-2.1+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
# gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y13.2c -N -O \
  #  -F+f12p,0,black+jLB >> $ps << EOF
# 0.2 10.0 Location of Landsat OLI/TIRS 8-9 satellite images: rotated cyan-colored  # square
# EOF
# Convert to image file using GhostScript
gmt psconvert Topo_IT.ps -A1.5c -E720 -Tj -Z
