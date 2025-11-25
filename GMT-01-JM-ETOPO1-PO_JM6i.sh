#!/bin/sh
# Purpose: shaded relief grid raster map from the ETOPO1 from 1 arc minute global data set (here: Pacific Ocean)
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert
# Eckert IV equal-area pseudocylindrical projection
# here: centered Pacific Ocean (180 grad)

# GMT set up
gmt set FORMAT_GEO_MAP=dddF \
    MAP_FRAME_PEN=dimgray \
    MAP_FRAME_WIDTH=0.1c \
    MAP_TITLE_OFFSET=1.0c \
    MAP_ANNOT_OFFSET=0.1c \
    MAP_TICK_PEN_PRIMARY=thinner,dimgray \
    MAP_GRID_PEN_PRIMARY=thinnest,white \
    MAP_GRID_PEN_SECONDARY=thinnest,white \
    MAP_GRID_CROSS_SIZE=thinnest \
    FONT_TITLE=12p,Palatino-Roman,black \
    FONT_ANNOT_PRIMARY=7p,Helvetica,dimgray \
    FONT_LABEL=7p,Helvetica,dimgray \
    
# Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults

exec bash

# Extract a subset of ETOPO1m . format: -R0/360/-90/90
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R110/295/-70/70 -Gpo_relief.nc
gmt grdinfo po_relief.nc
# z#actual_range={-10898,6560}


# Make color palette
#gmt makecpt -Cgeo.cpt -V -T-10898/6560 > poocean.cpt
#gmt makecpt -CSCM/grayC -V -T-10898/6560 > poocean.cpt
gmt makecpt -Cgmt/nighttime -V -T-10898/6560 > poocean.cpt

# Generate a file
ps=BathymetryPO.ps
# Make raster image
#gmt grdimage po_relief.nc -Cpoocean.cpt -R -JY180/0/6.5i -I+a15+ne0.75 -Xc -K > $ps
gmt grdimage po_relief.nc -Cpoocean.cpt -R110/295/-70/70 -JM7.5i -I+a15+ne0.75 -Xc -K > $ps

# Add color legend
gmt psscale -Dg80/-70+w13.5c/0.4c+h+o0.3/0i+ml \
    -Rpo_relief.nc -J -Cpoocean.cpt \
	--FONT_LABEL=9p,1,dimgray \
	--FONT_ANNOT_PRIMARY=9p,1,dimgray \
	-Baf+l"Topographic color scale: geo (global relief [R=-10898/6560, H=0, C=RGB])" \
	-I0.2 -By+lm -O -K >> $ps
    
# Add shorelines
gmt grdcontour po_relief.nc -R -J -C5000 -W0.05p,black -O -K >> $ps

# Add grid with major and minor lines
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=WEsN \
    -Bxg20f10a10 -Byg20f10a10 \
    --MAP_GRID_PEN_PRIMARY=thinnest,white \
    --MAP_GRID_PEN_SECONDARY=thinnest,white \
    --MAP_TITLE_OFFSET=1.0c \
    -B+t"Bathymetry of the Pacific Ocean and land topography" -O -K >> $ps
    
# Add scale bar
gmt psbasemap -R -J \
    --FONT=10p,1,black \
    --MAP_TITLE_OFFSET=0.3c \
    -Lx14c/-1.2c+c50+w3000k+l"Mercator projection. Scale (km)"+f \
    -UBL/0.0c/-2.5c -O -K >> $ps

###################################
# Texts
gmt pstext -R -J -N -O -K \
-F+jTL+f7p,Times−Bold,yellow+jLB+a-353 >> $ps << EOF
185.0 35.4 Mendocino Fracture Zone
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f7p,Times−Bold,yellow+jLB+a-350 >> $ps << EOF
203.0 28.4 Murray Fracture Zone
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f7p,Times−Bold,yellow+jLB+a-353 >> $ps << EOF
206.0 21.0 Molokai Fracture Zone
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f7p,Times−Bold,yellow+jLB+a-350 >> $ps << EOF
211.0 15.2 Clarion Fracture Zone
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f7p,Times−Bold,yellow+jLB+a-349 >> $ps << EOF
212.0 4.0 Clipperton Fracture Zone
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f5p,Times−Bold,yellow+jLB+a-17 >> $ps << EOF
182.0 25.0 Hawaiian Archipelago
#184.0 24.5 Archipelago
EOF
#
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,Times−Bold,yellow+jLB+a-310 >> $ps << EOF
246.0 -55.0 E a s t
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,Times−Bold,yellow+jLB+a-250 >> $ps << EOF
250.0 -35.0 P a c i f i c
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,Times−Bold,yellow+jLB+a-315 >> $ps << EOF
248.0 -13.0 R i s e
EOF
gmt pstext -R -J -N -O -K \
-F+f7p,Times-Roman,black+jLB -Gwhite@45 >> $ps << EOF
176.0 -21.0 Fiji
189.0 -13.5 Samoa
EOF
#
gmt pstext -R -J -N -O -K \
-F+jTL+f7p,Times-Roman,black+jLB -Gwhite@40 >> $ps << EOF
122.0 -25.0 A U S T R A L I A
115.0 50.0 A S I A
245.0 45.5 N O R T H
245.0 42.0 A M E R I C A
282.0 -5.0 SOUTH
282.0 -7.8 AMERICA
EOF
###################################

# Step-11. Add GMT logo
gmt logo -Dx6.5/-2.2+o0.1i/0.1i+w2c -O -K >> $ps

# Step-12. Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X1.0c -Y4.5c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
3.0 9.0 ETOPO1 Global Relief Model 1 arc min resolution grid
EOF

# Step-13. Convert to image file using GhostScript
gmt psconvert BathymetryPO.ps -A0.5c -E720 -Tj -Z
