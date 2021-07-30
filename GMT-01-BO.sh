#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO dataset (here: Bolivia)
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert
# http://soliton.vm.bytemark.co.uk/pub/cpt-city/wkp/encyclopedia/index.html

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

gmt grdcut GEBCO_2019.nc -R290/302.5/-23/-9 -Gbo_relief.nc
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R290/302.5/-23/-9 -Gbo_relief1.nc
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R290/302.5/-23/-9 -Gbo_relief.nc

gdalinfo bo_relief.nc -stats
# Minimum=-5319.000, Maximum=6560.000, Mean=-649.924, StdDev=2059.874

#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R290/302.5/-23/-9 -Dh -M -EBO > bo.txt
#####################################################################

# Make color palette
# makecpt --help
# gmt makecpt -Cgeo.cpt -V -T-100/6560 > pauline.cpt
# gmt makecpt -Cc3t3.cpt > pauline.cpt
# gmt makecpt -Cc3t3.cpt -V -T-100/6560 > pauline.cpt
gmt makecpt -Cnordisk-familjebok.cpt -V -T-100/6560 > pauline.cpt

# Generate a file
ps=Topography_BO.ps
# Make background transparent image
gmt grdimage bo_relief.nc -Cpauline.cpt -R290/302.5/-23/-9 -JM6i -P -I+a15+ne0.75 -t50 -Xc -K > $ps
    
# Add isolines
gmt grdcontour bo_relief.nc -R -J -C500 -W0.1p -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P \
    -Ia/thinner,blue -Na -N1/thickest,darkred -W0.1p -Df -O -K >> $ps
    
#####################################################################
# CLIPPING
# 1. Start: clip the map by mask to only include country

gmt psclip -R290/302.5/-23/-9 -JM6.0i bo.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage bo_relief.nc -Cpauline.cpt -R290/302.5/-23/-9 -JM6.0i -I+a15+ne0.75 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour bo_relief.nc -R -J -C500 -Wthinnest,darkbrown -O -K >> $ps
# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps

# 3: Undo the clipping
gmt psclip -C -O -K >> $ps
#####################################################################

# Add color barlegend
gmt psscale -Dg290/-23.8+w15.2c/0.4c+h+o0.0/0i+ml -R -J -Cpauline.cpt \
    --FONT_LABEL=8p,Helvetica,black \
    --MAP_LABEL_OFFSET=0.1c \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,black \
    -Baf+l"Color scale 'nordisk-familjebok' by Wikipedia elevation schemes [R=-6857/3206, H=0, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=WEsN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    -Bpx4f2a2 -Bpyg4f2a2 -Bsxg2 -Bsyg2 \
    --MAP_TITLE_OFFSET=1.0c \
    --FONT_TITLE=14p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=7p,Helvetica,black \
    -B+t"Topographic map of Bolivia" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=10p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=8p,Helvetica,black \
    --MAP_LABEL_OFFSET=0.1c \
    -Lx12.8c/-2.3c+c50+w200k+l"Mercator projection. Scale: km"+f \
    -UBL/-5p/-65p -O -K >> $ps
    
# Texts -R290/302.5/-23/-9
# Cities
gmt pstext -R -J -N -O -K \
-F+f12p,0,white+jLB+a-0 >> $ps << EOF
296.92 -18.0 Santa Cruz de la Sierra
EOF
gmt psxy -R -J -Sc -W0.5p -Ggold -O -K << EOF >> $ps
296.82 -17.8 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,0,black+jLB+a-0 -Gwhite@60 >> $ps << EOF
291.94 -16.72 El Alto
EOF
gmt psxy -R -J -Sc -W0.5p -Ggold -O -K << EOF >> $ps
291.84 -16.52 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f14p,0,black+jLB+a-0 -Gwhite@60 >> $ps << EOF
223.80 -16.5 La Paz
EOF
gmt psxy -R -J -Sc -W0.5p -Gred -O -K << EOF >> $ps
223.70 -16.5 0.25c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,0,white+jLB+a-0 >> $ps << EOF
294.0 -17.38 Cochabamba
EOF
gmt psxy -R -J -Sc -W0.5p -Ggold -O -K << EOF >> $ps
293.83 -17.38 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,0,black+jLB+a-0 -Gwhite@60 >> $ps << EOF
292.2 -17.80 Oruro
EOF
gmt psxy -R -J -Sc -W0.5p -Ggold -O -K << EOF >> $ps
292.88 -17.96 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,0,black+jLB+a-0 -Gwhite@60 >> $ps << EOF
294.85 -19.05 Sucre
EOF
gmt psxy -R -J -Sc -W0.5p -Ggold -O -K << EOF >> $ps
294.75 -19.05 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,0,black+jLB+a-0 -Gwhite@60 >> $ps << EOF
295.66 -21.32 Tarija
EOF
gmt psxy -R -J -Sc -W0.5p -Ggold -O -K << EOF >> $ps
295.56 -21.32 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,0,black+jLB+a-0 -Gwhite@60 >> $ps << EOF
293.5 -19.9 Potosí
EOF
gmt psxy -R -J -Sc -W0.5p -Ggold -O -K << EOF >> $ps
294.25 -19.58 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,0,black+jLB+a-0 -Gwhite@60 >> $ps << EOF
294.06 -17.65 Sacaba
EOF
gmt psxy -R -J -Sc -W0.5p -Ggold -O -K << EOF >> $ps
293.96 -17.40 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,0,black+jLB+a-0 -Gwhite@60 >> $ps << EOF
293.92 -18.0 Quillacollo
EOF
gmt psxy -R -J -Sc -W0.5p -Ggold -O -K << EOF >> $ps
293.72 -17.4 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,0,white+jLB+a-0 >> $ps << EOF
296.85 -17.25 Montero
EOF
gmt psxy -R -J -Sc -W0.5p -Ggold -O -K << EOF >> $ps
296.75 -17.34 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,0,white+jLB+a-0 >> $ps << EOF
295.20 -14.8 La Santísima
295.20 -15.1 Trinidad
EOF
gmt psxy -R -J -Sc -W0.5p -Ggold -O -K << EOF >> $ps
295.10 -14.83 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,0,black+jLB+a-0 -Gwhite@60 >> $ps << EOF
296.13 -21.90 Yacuíba
EOF
gmt psxy -R -J -Sc -W0.5p -Ggold -O -K << EOF >> $ps
296.33 -22.02 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,0,white+jLB+a-0 >> $ps << EOF
296.94 -17.60 Warnes
EOF
gmt psxy -R -J -Sc -W0.5p -Ggold -O -K << EOF >> $ps
296.84 -17.52 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,0,white+jLB+a-0 >> $ps << EOF
293.04 -11.40 Riberalta
EOF
gmt psxy -R -J -Sc -W0.5p -Ggold -O -K << EOF >> $ps
293.94 -11.01 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,0,black+jLB+a-0 -Gwhite@60 >> $ps << EOF
291.0 -16.95 Viacha
EOF
gmt psxy -R -J -Sc -W0.5p -Ggold -O -K << EOF >> $ps
291.7 -16.65 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,0,white+jLB+a-0 >> $ps << EOF
294.68 -16.97 Villa Tunari
EOF
gmt psxy -R -J -Sc -W0.5p -Ggold -O -K << EOF >> $ps
294.58 -16.97 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,0,black+jLB+a-0 -Gwhite@60 >> $ps << EOF
292.6 -17.20 Tiquipaya
EOF
gmt psxy -R -J -Sc -W0.5p -Ggold -O -K << EOF >> $ps
293.79 -17.8 0.20c
EOF
# water
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,24,blue+jLB -Gwhite@60 >> $ps << EOF
290.5 -15.55 Lake
290.5 -15.80 Titicaca
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,24,blue1+jLB -Gwhite@60 >> $ps << EOF
291.17 -16.23 Lago
291.17 -16.50 Huiñaymarca
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,24,blue+jLB -Gwhite@60 >> $ps << EOF
292.92 -18.75 Lake
292.92 -19.0 Poopó
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,24,black+jLB -Gwhite@60 >> $ps << EOF
292.0 -20.13 Salar
292.0 -20.38 de Uyuni
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,24,black+jLB -Gwhite@60 >> $ps << EOF
291.88 -19.10 Salar
291.88 -19.40 de Coipasa
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,24,blue+jLB -Gwhite@60 >> $ps << EOF
292.60 -18.25 Uru Uru
292.60 -18.50 Lake
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,23,cadetblue2+jLB >> $ps << EOF
295.35 -13.60 Laguna
295.35 -13.88 San Luis
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,23,cadetblue2+jLB >> $ps << EOF
292.02 -13.96 Laguna
292.02 -14.23 Rogagua
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,23,cadetblue2+jLB >> $ps << EOF
294.06 -13.03 Laguna
294.06 -13.31 Rogaguado
EOF
# geography
gmt pstext -R -J -N -O -K \
-F+jTL+f13p,3,darkred+jLB+a-60 -Gwhite@60 >> $ps << EOF
294.0 -18.55 Cordillera Real
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f13p,3,darkred+jLB+a-63 -Gwhite@60 >> $ps << EOF
291.0 -19.0 Cordillera Occidental
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f13p,3,darkred+jLB+a-60 -Gwhite@60 >> $ps << EOF
293.1 -20.13 Altiplano
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f13p,10,mintcream+jLB+a-345 >> $ps << EOF
298.5 -19.13 Gran Chaco
EOF
# countries
gmt pstext -R -J -N -O -K \
-F+jTL+f22p,25,gold+jLB >> $ps << EOF
294.0 -16.6 B  O  L  I  V  I  A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,25,firebrick4+jLB >> $ps << EOF
296.0 -11.0 B  R  A  Z  I  L
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,25,black+jLB+a-270 -Gwhite@60 >> $ps << EOF
290.5 -15.0 P E R U
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,25,black+jLB -Gwhite@60 >> $ps << EOF
294.0 -22.85 A R G E N T I N A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,25,black+jLB -Gwhite@60 >> $ps << EOF
290.0 -21.8 C H I L E
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,25,firebrick4+jLB >> $ps << EOF
298.2 -21.5 P A R A G U A Y
EOF
# rivers -R290/302.5/-23/-9
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,azure1+jLB+a-298 >> $ps << EOF
293.1 -13.2 Beni
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,azure1+jLB+a-330 >> $ps << EOF
291.6 -13.2 Madidi
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,lightblue+jLB+a-0 >> $ps << EOF
292.1 -11.90 Madidi
292.0 -12.15 National
292.2 -12.40 Park
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,azure1+jLB+a-310 >> $ps << EOF
294.0 -15.1 Apere
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,azure1+jLB+a-340 >> $ps << EOF
293.3 -14.1 Yacuma
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,azure1+jLB+a-80 >> $ps << EOF
295.0 -15.1 Mamoré
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,azure1+jLB+a-45 >> $ps << EOF
296.5 -13.1 San Martín
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,azure1+jLB+a-60 >> $ps << EOF
298.2 -14.3 Paragúa
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,azure1+jLB+a-67 >> $ps << EOF
296.90 -15.0 Blanco
EOF


# insert map
# Countries codes: ISO 3166-1 alpha-2. Continent codes AF (Africa), AN (Antarctica), AS (Asia), EU (Europe), OC (Oceania), NA (North America), or SA (South America). -EEU+ggrey
gmt psbasemap -R -J -O -K -DjTR+w3.0c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thinner,white -Rg -JG300/16S/$w -Da -Gbrown -A5000 -Bg -Wfaint -ESA+gpeachpuff -EBO+gyellow -Slightblue2 -O -K -X$x0 -Y$y0 >> $ps
#gmt pscoast -Rg -JG12/5N/$w -Da -Gbrown -A5000 -Bg -Wfaint -ECM+gbisque -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx6.2/-3.0+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y9.5c -N -O \
    -F+f12p,Helvetica,black+jLB >> $ps << EOF
1.5 13.6 SRTM/GEBCO 15 arc sec resolution global terrain model grid
EOF

# Convert to image file using GhostScript
gmt psconvert Topography_BO.ps -A0.5c -E720 -Tj -Z
