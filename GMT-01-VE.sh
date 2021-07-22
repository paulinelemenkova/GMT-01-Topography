#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO dataset (here: Venezuela)
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert
# http://soliton.vm.bytemark.co.uk/pub/cpt-city/arendal/tn/arctic.png.index.html

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
    FONT_ANNOT_PRIMARY=7p,Helvetica,dimgray \
    FONT_LABEL=7p,Helvetica,dimgray
# Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults

chsh -s /bin/bash

chsh -s /bin/zsh

gmt grdcut GEBCO_2019.nc -R286/300.5/0/12.5 -Gve_relief.nc
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R286/300.5/0/12.5 -Gve_relief1.nc

gdalinfo ve_relief.nc -stats
# Minimum=-4947.963, Maximum=5535.625, Mean=162.220, StdDev=788.097

#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R286/300.5/0/12.5 -Dh -M -EVE > ve.txt
#####################################################################

# Make color palette
# makecpt --help
# gmt makecpt -Cgeo.cpt -V -T-4947/5535 > pauline.cpt
# gmt makecpt -Cafrikakarte.cpt > pauline.cpt
gmt makecpt -Carctic.cpt > pauline.cpt

# Generate a file
ps=Topography_VE.ps
# Make background transparent image
gmt grdimage ve_relief.nc -Cpauline.cpt -R286/300.5/0/12.5 -JM6i -P -I+a15+ne0.75 -t20 -Xc -K > $ps
    
# Add isolines
gmt grdcontour ve_relief1.nc -R -J -C500 -W0.1p -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P \
    -Ia/thinner,blue -Na -N1/thickest,darkred -W0.1p -Df -O -K >> $ps
    
#####################################################################
# CLIPPING
# 1. Start: clip the map by mask to only include country

gmt psclip -R286/300.5/0/12.5 -JM6.0i ve.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage ve_relief.nc -Cpauline.cpt -R286/300.5/0/12.5 -JM6.0i -I+a15+ne0.75 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour ve_relief1.nc -R -J -C1000 -Wthinner,darkbrown -O -K >> $ps
# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps

# 3: Undo the clipping
gmt psclip -C -O -K >> $ps
#####################################################################

# Add color barlegend
gmt psscale -Dg286/-1.0+w15.2c/0.4c+h+o0.0/0i+ml -R -J -Cpauline.cpt \
    --FONT_LABEL=8p,Helvetica,black \
    --MAP_LABEL_OFFSET=0.1c \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,black \
    -Bg500a1000f100+l"Color scale 'arctic': global bathymetry/topography relief [-5000 to 4000, mixed, RGB, 110 segments]" \
    -I0.2 -By+lm -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=WEsN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    -Bpx4f2a2 -Bpyg4f2a2 -Bsxg4 -Bsyg2 \
    --MAP_TITLE_OFFSET=0.8c \
    --FONT_TITLE=14p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=7p,Helvetica,black \
    -B+t"Topographic map of Venezuela, Trinidad and Tobago" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=9p,0,black \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --MAP_LABEL_OFFSET=0.1c \
    -Lx12.7c/-2.2c+c50+w200k+l"Mercator projection. Scale: km"+f \
    -UBL/-5p/-65p -O -K >> $ps
    
# Texts
gmt pstext -R -J -N -O -K \
-F+f10p,17,black+jLB+a-0 -Gwhite@60 >> $ps << EOF
293.20 10.58 Caracas
EOF
gmt psxy -R -J -Sc -W0.5p -Gred -O -K << EOF >> $ps
293.10 10.48 0.30c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB+a-0 -Gwhite@60 >> $ps << EOF
288.07 10.80 Maracaibo
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
288.37 10.63 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB+a-0 -Gwhite@60 >> $ps << EOF
291.30 10.38 Valencia
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
292 10.18 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB+a-0 -Gwhite@60 >> $ps << EOF
290.67 9.60 Barquisimeto
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
290.67 10.06 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB+a-0 -Gwhite@60 >> $ps << EOF
297.45 8.20 Ciudad
297.45 7.90 Guayana
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
297.35 8.36 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB+a-0 -Gwhite@60 >> $ps << EOF
296.2 9.35 Maturín
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
296.82 9.75 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB+a-0 -Gwhite@60 >> $ps << EOF
294.60 9.75 Barcelona
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
295.28 10.12 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB+a-0 -Gwhite@60 >> $ps << EOF
292.4 9.90 Maracay
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
292.4 10.25 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB+a-0 -Gwhite@60 >> $ps << EOF
295.93 10.46 Cumaná
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
295.83 10.46 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB+a-0 -Gwhite@60 >> $ps << EOF
289.9 8.63 Barinas
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
289.8 8.63 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB+a-0 >> $ps << EOF
294.20 8.24 Ciudad Bolívar
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
296.45 8.14 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB+a-0 -Gwhite@60 >> $ps << EOF
287.87 7.76 San Cristóbal
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
287.77 7.76 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB+a-0 -Glightgreen@60 >> $ps << EOF
291.80 7.80 San
291.80 7.55 Fernando
291.80 7.30 de Apure
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
292.53 7.89 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB+a-0 -Gwhite@60 >> $ps << EOF
299.4 2.4 Boa
299.4 2.1 Vista
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
299.33 2.82 0.20c
EOF
# countries
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,25,black+jLB -Gwhite@60 >> $ps << EOF
297.8 11.20 TOBAGO
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,25,black+jLB -Gwhite@60 >> $ps << EOF
298.75 10.20 TRINIDAD
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,25,black+jLB >> $ps << EOF
289.1 5.0 C O L O M B I A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,25,black+jLB -Ghoneydew@60 >> $ps << EOF
297.0 1.0 B  R  A  Z  I  L
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,25,black+jLB -Gwhite@60 >> $ps << EOF
298.85 6.10 GUYANA
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f16p,25,firebrick4+jLB >> $ps << EOF
290.9 6.70 V  E  N  E  Z  U  E  L  A
EOF
# water
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,17,darkslateblue+jLB -Glavender@60 >> $ps << EOF
292.2 11.5 C a r i b b e a n  S e a
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,21,blue1+jLB >> $ps << EOF
288.07 9.9 Lake
288.0 9.6 Maracaibo
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,21,blue1+jLB >> $ps << EOF
288.5 11.5 Golfo de
288.3 11.2 Venezuela
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,21,blue1+jLB >> $ps << EOF
297.5 10.4 Golfo
297.5 10.1 de Paria
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,21,blue1+jLB >> $ps << EOF
291.9 10.7 Golfo
291.9 10.4 Triste
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,26,blue1+jLB+a-342 >> $ps << EOF
295.35 7.4 Rio Orinoco
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,21,blue1+jLB+a-335 >> $ps << EOF
290.0 7.4 Apure
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,21,blue1+jLB >> $ps << EOF
290.0 7.1 Arauca
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,21,blue1+jLB+a-80 >> $ps << EOF
298.0 6.8 Cuyuni
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,21,blue1+jLB >> $ps << EOF
296.8 7.6 Embalse
296.8 7.3 de Guri
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,21,blue1+jLB+a-12 >> $ps << EOF
290.2 9.2 Portuguesa
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,21,blue1+jLB+a-9 >> $ps << EOF
292.90 7.9 Guarico
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,21,blue1+jLB+a-75 >> $ps << EOF
295.20 6.1 Caura
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,21,blue1+jLB+a-7 >> $ps << EOF
295.83 9.1 Tigre
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,21,blue1+jLB+a-290 >> $ps << EOF
296.0 5.7 Paragua
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,21,white+jLB >> $ps << EOF
298.0 9.2 Orinoco
298.0 8.8 Delta
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,21,blue1+jLB >> $ps << EOF
288.2 6.35 Río Casanare
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,21,blue1+jLB+a-330 >> $ps << EOF
288.07 4.5 Río Meta
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,21,blue1+jLB+a-345 >> $ps << EOF
288.80 4.1 Río Vichada
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,21,blue1+jLB+a-350 >> $ps << EOF
289.8 3.6 Río Guaviare
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,21,blue1+jLB+a-330 >> $ps << EOF
290.7 2.85 Río Inírida
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,21,blue1+jLB+a-325 >> $ps << EOF
291.2 2.3 Río Guainía
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,21,blue1+jLB+a-293 >> $ps << EOF
298.75 1.8 Branco
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,21,blue1+jLB+a-350 >> $ps << EOF
297.9 2.9 Uraricoera
EOF

#
# geography
gmt pstext -R -J -N -O -K \
-F+jTL+f13p,25,darkgreen+jLB+a-0 >> $ps << EOF
293.5 2.8 Amazon
293.5 2.3 Forests
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,25,darkred+jLB+a-0 -Gwhite@60 >> $ps << EOF
293.8 5.0 Guiana Highlands
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,25,darkred+jLB+a-0 -Gwhite@60 >> $ps << EOF
297.8 5.5 Gran
297.7 5.0 Sabana
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,21,darkred+jLB+a-50 -Gwhite@60 >> $ps << EOF
294.2 4.8 Sierra Parima
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,21,white+jLB+a-320 -Gnavajowhite4@80 >> $ps << EOF
288.3 8.1 Cordillera de Mérida
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,21,white+jLB+a-315 -Gnavajowhite4@80 >> $ps << EOF
286.7 5.8 Los Andes
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,32,darkgreen+jLB+a-330 >> $ps << EOF
290.8 7.8 Los Llanos
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,21,darkred+jLB+a-0 -Gwhite@60 >> $ps << EOF
290.1 12.1 Paraguaná
290.1 11.8 Peninsula
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,21,darkred+jLB+a-0 -Gwhite@60 >> $ps << EOF
290.0 11.1 Lara-Falcón
290.0 10.8 Formación
290.0 10.5 (Coro)
EOF

# insert map
# Countries codes: ISO 3166-1 alpha-2. Continent codes AF (Africa), AN (Antarctica), AS (Asia), EU (Europe), OC (Oceania), NA (North America), or SA (South America). -EEU+ggrey
gmt psbasemap -R -J -O -K -DjBL+w3.3c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thinner,white -Rg -JG293/6N/$w -Da -Gbrown -A5000 -Bg -Wfaint -ESA+gpeachpuff -EVE+gyellow -Slightsteelblue3 -O -K -X$x0 -Y$y0 >> $ps
#gmt pscoast -Rg -JG12/5N/$w -Da -Gbrown -A5000 -Bg -Wfaint -ECM+gbisque -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx6.2/-2.9+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y5.0c -N -O \
    -F+f10p,Helvetica,black+jLB >> $ps << EOF
2.3 13.3 SRTM/GEBCO 15 arc sec resolution global terrain model grid
EOF

# Convert to image file using GhostScript
gmt psconvert Topography_VE.ps -A0.5c -E720 -Tj -Z
