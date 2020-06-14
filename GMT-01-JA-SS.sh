#!/bin/sh
# Purpose: shaded relief grid raster map from the ETOPO1 from 1 arc minute global data set (here: Scotia Sea)
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert

# Step-2. GMT set up
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
# Step-3. Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults

#grdcut ETOPO1_Ice_g_gmt4.grd -R270/371/-72/-44 -Gss_relief.nc
grdcut GEBCO_2019.nc -R270/371/-72/-44 -Gss_relief.nc

gdalinfo ss_relief.nc -stats
# Step-5. Make color palette
gmt makecpt -Cgeo.cpt -V -T-8239/6392 > myocean.cpt
#makecpt --help

# Generate a file
ps=Bathymetry_SS.ps
gmt grdimage ss_relief.nc -Cmyocean.cpt -R270/-65/340/-45r -JA318/-57/5.5i -P -I+a15+ne0.75 -Xc -K > $ps

# Add shorelines
gmt grdcontour ss_relief.nc -R -J -C2000 -W0.1p -O -K >> $ps

# Add grid
gmt psbasemap -R -J \
    -Bpx104f5a5 -Bpyg10f5a5 -Bsxg5 -Bsyg5 \
    --MAP_TITLE_OFFSET=1.5c \
    --MAP_ANNOT_OFFSET=0.1c \
    -B+t"Topographic map of the Scotia Sea region" \
    -Lx12.0c/-1.3c+c318/-57+w1000k+l"Scale (km) at 42\232W 57\232S"+f \
    -UBL/-5p/-40p -O -K >> $ps

# Texts
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,Helvetica,white+jLB >> $ps << EOF
318 -67.0 W E D D E L L
322 -68.5 S E A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,Helvetica,white+jLB >> $ps << EOF
308 -57.0 S C O T I A   S E A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,Times−Bold,black+jLB -Gwhite@40 >> $ps << EOF
291 -67.0 Antarctic
290 -67.8 Peninsula
321.5 -52.5 South
321.5 -53.3 Georgia
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Times−Bold,black+jLB -Gwhite@40 >> $ps << EOF
318 -48.5 A T L A N T I C  O C E A N
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Times−Bold,black+jLB+a-330 -Gwhite@40 >> $ps << EOF
279.5 -62.0 PACIFIC
279.5 -62.9 OCEAN
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,Times−Bold,black+jLB+a-25 -Gwhite@40 >> $ps << EOF
287 -53.5 Chile
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,Times−Bold,black+jLB+a-285 -Gwhite@40 >> $ps << EOF
289.5 -50.5 Argentina
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,Times−Bold,black+jLB -Gwhite@40 >> $ps << EOF
300 -49.8 Falkland
300 -50.6 Islands
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,Times−Bold,black+jLB -Gwhite@40 >> $ps << EOF
328 -57.0 South
327 -58.0 Sandwich
328 -59.0 Islands
EOF

# Add legend
gmt psscale -Dg260/-64+w10.0c/0.4c+v+o-7.0c/-5.3c+ml -R270/340/-65/-45 -J -Cmyocean.cpt \
    --FONT_LABEL=7p,Helvetica,dimgray \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,black \
    -Baf+l"Color scale: geo global bathymetry/topography relief [R=-8239/6392, H=0, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps

# Add GMT logo
gmt logo -Dx5.8/-2.2+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y6.7c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
#2.1 7.4 ETOPO1 global terrain model, 1 arc min resolution grid
2.1 7.4 GEBCO global terrain model, 15 arc sec resolution grid
0.0 6.8 Lambert Azimuthal Equal-Area projection. Central meridian 42\232W, parallel 57\232S
EOF

# Convert to image file using GhostScript
gmt psconvert Bathymetry_SS.ps -A0.5c -E720 -Tj -Z
