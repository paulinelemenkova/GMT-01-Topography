#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO dataset (here: Paraguay)
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

#gmt grdcut GEBCO_2019.nc -R297/306/-28/-19 -GParaguay_relief.nc
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R297/306/-28/-19 -GParaguay_relief.nc

gdalinfo Paraguay_relief.nc -stats
# Minimum=51.000, Maximum=882.000, Mean=202.711, StdDev=125.633

#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R297/306/-28/-19 -Dh -M -EPY > Paraguay.txt
#gmt pscoast -Dh -M -ELB > Malawi.txt
#####################################################################

# Make color palette
# makecpt --help
gmt makecpt -Cgeo.cpt -V -T51/882 > pauline.cpt

# Generate a file
ps=Topography_Paraguay.ps
# Make background transparent image
gmt grdimage Paraguay_relief.nc -Cpauline.cpt -R297/306/-28/-19 -JM6i -P -I+a15+ne0.75 -t50 -Xc -K > $ps
    
# Add isolines
gmt grdcontour Paraguay_relief.nc -R -J -C50 -W0.1p -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P \
    -Ia/thinner,blue -Na -N1/thickest,red -W0.1p -Df -O -K >> $ps
    
#####################################################################
# CLIPPING
# 1. Start: clip the map by mask to only include country

gmt psclip -R297/306/-28/-19 -JM6.0i Paraguay.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage Paraguay_relief.nc -Cpauline.cpt -R297/306/-28/-19 -JM6.0i -I+a15+ne0.75 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour Paraguay_relief1.nc -R -J -C50 -Wthinnest,darkbrown -O -K >> $ps
# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps

# 3: Undo the clipping
gmt psclip -C -O -K >> $ps
#####################################################################

# Add color barlegend
gmt psscale -Dg297/-28.6+w15.2c/0.4c+h+o0.0/0i+ml -R -J -Cpauline.cpt \
    --FONT_LABEL=8p,Helvetica,black \
    --MAP_LABEL_OFFSET=0.1c \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,black \
    -Ba100g100f10+l"Color scale 'geo': global bathymetry/topography relief [R=-6857/3206, H=0, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=WEsN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    -Bpx1f1a2 -Bpyg1f1a2 -Bsxg1 -Bsyg1 \
    --MAP_TITLE_OFFSET=1.2c \
    --FONT_TITLE=14p,0,black \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    -B+t"Topographic map of Paraguay" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=10p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=8p,Helvetica,black \
    --MAP_LABEL_OFFSET=0.1c \
    -Lx12.7c/-2.3c+c50+w200k+l"Mercator projection. Scale: km"+f \
    -UBL/-5p/-65p -O -K >> $ps
    
# Texts
# countries -R297/306/-28/-19
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,19,black+jLB -Gwhite@50 >> $ps << EOF
297.3 -19.3 B O L I V I A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,25,black+jLB -Gwhite@50 >> $ps << EOF
303.5 -21.5 B R A Z I L
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,25,black+jLB >> $ps << EOF
299.2 -26.5 A R G E N T I N A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f16p,27,white+jLB >> $ps << EOF
299.5 -22.9 P A R A G U A Y
EOF
# geography
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,22,BURLYWOOD4+jLB+a-310 >> $ps << EOF
299.0 -25.0 G R A N   C H A C O
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f13p,22,khaki1+jLB >> $ps << EOF
298.1 -21.5 CHACO BOREAL
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,22,BURLYWOOD4+jLB >> $ps << EOF
299.8 -25.0 C H A C O
299.6 -25.3 C E N T R A L
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,22,BURLYWOOD4+jLB >> $ps << EOF
299.2 -25.9 C H A C O  A S T R A L
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,17,yellow+jLB -GSADDLEBROWN@80 >> $ps << EOF
303.0 -24.8 O R I E N T A L
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,22,white+jLB -GSADDLEBROWN@50 >> $ps << EOF
304.7 -25.6 PARANA
304.7 -25.8 PLATEAU
EOF
# Parks
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,14,darkgreen+jLB >> $ps << EOF
298.0 -22.2 Teniente Encisco
298.0 -22.5 National Park
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,14,darkgreen+jLB >> $ps << EOF
299.5 -20.2 Defensores
299.8 -20.4 del Chaco
299.5 -20.6 National Park
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,13,white+jLB -GSADDLEBROWN@50 >> $ps << EOF
302.5 -22.5 Cerro Corá
302.5 -22.7 National Park
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,14,darkgreen+jLB >> $ps << EOF
300.3 -23.9 Tinfunque
300.3 -24.1 National Park
EOF

# mountains
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,23,white+jLB+a-70 -GSADDLEBROWN@50 >> $ps << EOF
304.1 -22.5 Cordillera
303.9 -22.5 de Amambay
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,23,white+jLB -GSADDLEBROWN@50 >> $ps << EOF
304.5 -24.2 Cordillera
304.5 -24.35 de Mbaracay
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,23,white+jLB+a-320 -GSADDLEBROWN@50 >> $ps << EOF
304.1 -26.7 Cordillera de
304.3 -26.8 San Rafael
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,23,white+jLB+a-70 -GSADDLEBROWN@50 >> $ps << EOF
304.1 -25.0 Cordillera de
304.0 -25.2 Caaguazú
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,23,white+jLB -GSADDLEBROWN@50 >> $ps << EOF
298.8 -20.2 Léon Hill
EOF

# rivers
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,blue1+jLB+a-55 >> $ps << EOF
258.6 30.0 Verde
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,blue1+jLB+a-55 >> $ps << EOF
258.6 30.0 Negro
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,blue1+jLB+a-55 >> $ps << EOF
258.6 30.0 Paraguay
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,blue1+jLB+a-55 >> $ps << EOF
258.6 30.0 Paraná
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,blue1+jLB+a-55 >> $ps << EOF
258.6 30.0 Aquidaban
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,blue1+jLB+a-55 >> $ps << EOF
258.6 30.0 Ypané
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,blue1+jLB+a-55 >> $ps << EOF
258.6 30.0 Paraguay
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,blue1+jLB+a-55 >> $ps << EOF
258.6 30.0 Lake
258.6 30.0 Trinidad
EOF
# cities

# insert map
# Countries codes: ISO 3166-1 alpha-2. Continent codes AF (Africa), AN (Antarctica), AS (Asia), EU (Europe), OC (Oceania), NA (North America), or SA (South America). -EEU+ggrey
gmt psbasemap -R -J -O -K -DjBL+w3.7c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thinnest,white -Rg -JG302/24S/$w -Da -Gbrown -A5000 -Bg -Wfaint -ESA+gpeachpuff -EPY+gyellow -Slightskyblue1 -O -K -X$x0 -Y$y0 >> $ps
#gmt pscoast -Rg -JG12/5N/$w -Da -Gbrown -A5000 -Bg -Wfaint -ECM+gbisque -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx6.5/-3.0+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y8.5c -N -O \
    -F+f12p,Helvetica,black+jLB >> $ps << EOF
1.5 13.6 SRTM/GEBCO 15 arc sec resolution global terrain model grid
EOF

# Convert to image file using GhostScript
gmt psconvert Topography_Paraguay.ps -A1.0c -E720 -Tj -Z
