#!/bin/sh
# Purpose: shaded relief grid raster map from the ETOPO1 from 1 arc minute global data set (here: Cascadia Trench)
# GMT modules: gmtset, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert

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
FONT_LABEL=7p,Helvetica,dimgray \

# Extract a subset of ETOPO1m for the Kuril-Kamchatka Trench area
#grdcut ETOPO1_Ice_g_gmt4.grd -R224/240/35/55 -Gct_relief.nc
grdcut GEBCO_2019.nc -R224/240/35/55 -Gct_relief.nc
gdalinfo ct_relief.nc -stats
# Minimum=-6201.000, Maximum=4161.000

# Make color palette
gmt makecpt -Cgeo.cpt -V -T-6201/4161 > myocean.cpt

# Generate a file
ps=BathymetryCT.ps
# Make raster image
gmt grdimage ct_relief.nc -Cmyocean.cpt -R224/240/35/55 -JM6i -P -I+a15+ne0.75 -Xc -K > $ps

# Add grid
gmt psbasemap -R -J \
    -Bpxg8f2a4 -Bpyg6f3a3 -Bsxg4 -Bsyg3 \
    --MAP_TITLE_OFFSET=1.0c \
    --FONT_ANNOT_PRIMARY=7p,Helvetica,black \
    -B+t"Topographic map of the Cascadia Subduction Zone region" -O -K >> $ps
    
gmt psxy -R -J trench.gmt -Sf1.5c/0.2c+l+t -Wthick,yellow -Gyellow -O -K >> $ps
    
# Add legend
gmt psscale -Dg217/35+w15.0c/0.4c+h+o7.0/-1.5c+ml -Rct_relief.nc -J -Cmyocean.cpt \
    --FONT_LABEL=8p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=8p,Helvetica,black \
    -Baf+l"Color scale: geo global bathymetry/topography relief [R=-6201/4161, H=0, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps
    
# Add shorelines
gmt grdcontour ct_relief.nc -R -J -C1000 -W0.1p -O -K >> $ps

# Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=8p,Helvetica,black \
    --MAP_TITLE_OFFSET=0.3c \
    -Lx13.4c/-2.7c+c50+w300k+l"Mercator projection. Scale (km)"+f \
    -UBL/0p/-75p -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P \
    -Ia/thick,blue -Na -N1/thickest,red -W0.1p -Df -O -K >> $ps

# Texts
# 224
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,Helvetica,black+jLB+a-43 -Gwhite@40 >> $ps << EOF
233 50.2 Vancouver Island
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f13p,Helvetica,white+jLB >> $ps << EOF
224.5 44.1 P A C I F I C
224.5 43.5 O C E A N
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,Helvetica,white+jLB >> $ps << EOF
236.1 51.2 C  A  N  A  D  A
238 43.0 U  S  A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f13p,Helvetica,red+jLB+a-49 -Gwhite@40 >> $ps << EOF
231 49.8 C a s c a d i a
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f13p,Helvetica,red+jLB+a-85 -Gwhite@40 >> $ps << EOF
234.2 46.0 T r e n c h
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f13p,Helvetica,black+jLB -Gwhite@40 >> $ps << EOF
228 53.5 Queen
228 53.2 Charlotte
228 52.9 Islands
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,Helvetica,black+jLB -Gwhite@40 >> $ps << EOF
233 53.0 British Columbia
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,Helvetica,black+jLB -Gwhite@40 >> $ps << EOF
237 45.5 Oregon
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,Helvetica,black+jLB -Gwhite@40 >> $ps << EOF
237 41.0 California
EOF
    
# Add GMT logo
gmt logo -Dx6.4/-3.5+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/14 -X0.5c -Y7.0c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
3.0 22.7 GEBCO global terrain model 15 arc-sec resolution grid
EOF

# Convert to image file using GhostScript
gmt psconvert BathymetryCT.ps -A2.5c -E720 -Tj -Z
