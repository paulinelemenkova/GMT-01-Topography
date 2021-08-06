#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO dataset (here: Mexico)
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
    FONT_ANNOT_PRIMARY=7p,Helvetica,dimgray \
    FONT_LABEL=7p,Helvetica,dimgray
# Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults

chsh -s /bin/bash

chsh -s /bin/zsh

#gmt grdcut GEBCO_2019.nc -R240/275/14/33 -Gmx_relief.nc
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R240/275/14/33 -Gmx_relief.nc
# Min=-7321.000 Max=3235.000

gdalinfo mx_relief.nc -stats
#

#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R240/275/14/33 -Dh -M -EMX > mx.txt
#####################################################################

# Make color palette
# makecpt --help
gmt makecpt -Cgeo.cpt -V -T-7321/3235 > pauline.cpt

# Generate a file
ps=Topography_MX.ps
# Make background transparent image
gmt grdimage mx_relief.nc -Cpauline.cpt -R240/275/14/33 -JM6i -P -I+a15+ne0.75 -t50 -Xc -K > $ps
    
# Add isolines
gmt grdcontour mx_relief.nc -R -J -C1000 -W0.1p -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P \
    -Ia/thinner,blue -Na -N1/thicker,darkred -W0.1p -Df -O -K >> $ps
    
#####################################################################
# CLIPPING
# 1. Start: clip the map by mask to only include country

gmt psclip -R240/275/14/33 -JM6.0i mx.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage mx_relief.nc -Cpauline.cpt -R240/275/14/33 -JM6.0i -I+a15+ne0.75 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour mx_relief.nc -R -J -C1000 -Wthinnest,darkbrown -O -K >> $ps
# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thickest,gold1 -W0.1p -Df -O -K >> $ps

# 3: Undo the clipping
gmt psclip -C -O -K >> $ps
#####################################################################

# Add color barlegend
gmt psscale -Dg240/11.7+w15.3c/0.4c+h+o0.0/0i+ml+e -R -J -Cpauline.cpt \
    --FONT_LABEL=8p,Helvetica,black \
    --MAP_LABEL_OFFSET=0.1c \
    --FONT_ANNOT_PRIMARY=6p,0,black \
    -Bg500a1000f100+l"Color scale 'geo': global bathymetry/topography relief [R=-6857/3206, H=0, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=WEsN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    -Bpx4f2a4 -Bpyg8f4a4 -Bsxg4 -Bsyg2 \
    --MAP_TITLE_OFFSET=0.6c \
    --FONT_TITLE=13p,0,black \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    -B+t"Topographic map of Mexico" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=6p,0,black \
    --MAP_LABEL_OFFSET=0.1c \
    -Lx12.8c/-2.0c+c50+w800k+l"Mercator projection. Scale: km"+f \
    -UBL/-5p/-60p -O -K >> $ps
    
# Texts
# Cities
gmt pstext -R -J -N -O -K \
-F+f10p,21,black+jLB+a-0 -Gwhite@60 >> $ps << EOF
258.0 19.73 Mexico City
EOF
gmt psxy -R -J -Sc -W0.5p -Gred -O -K << EOF >> $ps
260.87 19.43 0.25c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,21,black+jLB+a-0 -Gwhite@60 >> $ps << EOF
257.3 16.3 Acapulco
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
260.12 16.86 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,21,black+jLB+a-0 -Gwhite@60 >> $ps << EOF
253.7 28.94 Chihuahua
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
253.9 28.64 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,21,black+jLB+a-0 -Gwhite@60 >> $ps << EOF
260.0 25.37 Monterrey
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
259.70 25.67 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,21,black+jLB+a-0 -Gwhite@60 >> $ps << EOF
256.3 23.6 Zacatecas
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
257.3 23.3 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,0,black+jLB+a-0 -Gwhite@60 >> $ps << EOF
254.55 27.43 Hidalgo
254.55 26.73 del Parral
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
254.34 26.93 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,0,black+jLB+a-0 -Gwhite@60 >> $ps << EOF
259.02 21.40 San Luis Potosí
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
259.02 22.15 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,0,black+jLB+a-0 -Gwhite@60 >> $ps << EOF
256.1 24.74 Torreón
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
256.55 25.54 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,0,black+jLB+a-0 -Gwhite@60 >> $ps << EOF
256.9 21.42 León
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
258.32 21.12 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,0,black+jLB+a-0 -Gwhite@60 >> $ps << EOF
261.82 18.33 Puebla
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
261.82 19.03 0.20c
EOF

# countries -R240/275/14/33
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,25,black+jLB >> $ps << EOF
257.5 31.0 United States of America
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,25,black+jLB -Gwhite@50 >> $ps << EOF
255.35 22.2 M E X I C O
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,22,black+jLB -Gwhite@50 >> $ps << EOF
268.1 15.0 Guatemala
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,22,black+jLB -Gwhite@50 >> $ps << EOF
271.0 17.0 Belize
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,22,black+jLB -Gwhite@50 >> $ps << EOF
271.4 14.3 Honduras
EOF

# water
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,26,blue1+jLB >> $ps << EOF
266 25 Gulf of Mexico
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,blue1+jLB >> $ps << EOF
264.2 20.0 Bay of
264.2 19.3 Campeche
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,blue1+jLB >> $ps << EOF
264.2 15.1 Gulf of
263.0 14.3 Tehuantepec
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,26,blue1+jLB >> $ps << EOF
241.1 21.0 P A C I F I C   O C E A N
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,26,blue1+jLB+a-55 >> $ps << EOF
246.0 30.2 Gulf of California
EOF

# mountains
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,23,black+jLB+a-25 -Gwhite@50 >> $ps << EOF
258.0 18.4 Sierra Madre del Sur
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,23,black+jLB+a-70 -Gwhite@60 >> $ps << EOF
257.5 29.0 Sierra Madre Oriental
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,23,black+jLB+a-62 -Gwhite@60 >> $ps << EOF
250.2 31.2 Sierra Madre Occidental
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,23,gold1+jLB+a-315 >> $ps << EOF
270.2 18.7 Yucatán
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,23,black+jLB+a-60 -Gwhite@60 >> $ps << EOF
243.8 31.9 Baja California
EOF
# rivers -R285/328/-35/6
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,blue1+jLB+a-55 >> $ps << EOF
258.6 30.0 Rio Grande
EOF

# insert map
# Countries codes: ISO 3166-1 alpha-2. Continent codes AF (Africa), AN (Antarctica), AS (Asia), EU (Europe), OC (Oceania), NA (North America), or SA (South America). -EEU+ggrey
gmt psbasemap -R -J -O -K -DjBL+w2.7c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thinner,white -Rg -JG270/15N/$w -Da -Gbrown -A5000 -Bg -Wfaint -ESA+gpeachpuff -EMX+gyellow -Sslategray3 -O -K -X$x0 -Y$y0 >> $ps
#gmt pscoast -Rg -JG12/5N/$w -Da -Gbrown -A5000 -Bg -Wfaint -ECM+gbisque -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx6.2/-2.8+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y0.0c -N -O \
    -F+f11p,0,black+jLB >> $ps << EOF
1.5 14.5 SRTM/GEBCO 15 arc sec resolution global terrain model grid
EOF

# Convert to image file using GhostScript
gmt psconvert Topography_MX.ps -A0.5c -E720 -Tj -Z
