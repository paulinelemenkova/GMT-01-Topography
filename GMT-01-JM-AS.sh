#!/bin/sh
# Purpose: shaded relief grid raster map from the ETOPO1 from 1 arc minute global data set (here: Gulf of Oman)
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

# makecpt --help
# Step-6. Make raster image
# gmt grdimage ETOPO1_Ice_g_gmt4.grd -Cmyocean.cpt -R120/134/-80/-40 -JM6i -P -I+a15+ne0.75 -Xc -K > $ps
#grdcut GEBCO_2019.nc -R56/74/15/30 -Goman_relief.nc
grdcut GEBCO_2019.nc -R47/77/0/31 -Garab_relief.nc

gdalinfo arab_relief.nc -stats
# Step-5. Make color palette
gmt makecpt -Cgeo.cpt -V -T-5760/4357 > myocean.cpt

# Generate a file
ps=Bathymetry_AS.ps
gmt grdimage arab_relief.nc -Cmyocean.cpt -R47/77/0/31 -JM6i -P -I+a15+ne0.75 -Xc -K > $ps
# gmt grdimage GEBCO_2019_SID.nc -Cmyocean.cpt -R140/170/40/60 -JM6i -P -I+a15+ne0.75 -Xc -K > $ps

# Add shorelines
gmt grdcontour arab_relief.nc -R -J -C1000 -W0.1p -O -K >> $ps

# Add grid
gmt psbasemap -R -J \
    -Bpx104f5a5 -Bpyg10f5a5 -Bsxg5 -Bsyg5 \
    --MAP_TITLE_OFFSET=0.8c \
    --FONT_TITLE=14p,Palatino-Roman,black \
    --FONT_ANNOT_PRIMARY=9p,Helvetica,black \
    --FONT_LABEL=8p,Helvetica,black \
    -B+t"Topographic map of the Arabian Sea region" -O -K >> $ps
    
# Add scale, directional rose
gmt psbasemap -R -J \
    --FONT_ANNOT_PRIMARY=9p,Helvetica,black \
    --FONT_LABEL=9p,Helvetica,black \
    --MAP_TITLE_OFFSET=0.3c \
    -Tdx13.7c/14.5c+w0.3i+f2+l+o0.15i \
    -Lx12.7c/-1.3c+c50+w700k+l"Mercator projection. Scale: km"+f \
    -UBL/-5p/-40p -O -K >> $ps

# Add legend
gmt psscale -Dg41.2/0+w16.5c/0.4c+v+o0.3/0i+ml -R47/77/0/31 -J -Cmyocean.cpt \
    --FONT_LABEL=8p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=8p,Helvetica,black \
    -Baf+l"Color scale 'geo': global bathymetry/topography relief [R=-5115/4127, H=0, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P -Ia/thinnest,blue -N1/thinner,red -Df -O -K >> $ps
#-Wthinner

# Texts
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Times−Bold,yellow+jLB >> $ps << EOF
63.0 20.8 Oman
62.0 20.3 Abyssal Plain
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,Times−Bold,yellow+jLB+a-290 >> $ps << EOF
60.2 17.0 Owen
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,Times−Bold,yellow+jLB+a-300 >> $ps << EOF
60.9 18.8 Fracture
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,Times−Bold,yellow+jLB+a-315 >> $ps << EOF
62.2 21.0 Zone
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Times−Bold,yellow+jLB >> $ps << EOF
60.0 22.6 Gulf of
60.1 22.0 Oman
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,Helvetica,white+jLB >> $ps << EOF
59.0 23.4 Makran Trench
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Times−Bold,black+jLB+a-335 -Gwhite@40 >> $ps << EOF
48.2 12.5 Gulf of Aden
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Times−Bold,black+jLB+a-49 >> $ps << EOF
49.5 29.0 P e r s i a n  G u l f
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,Times−Bold,black+jLB+a-325 -Gwhite@40 >> $ps << EOF
63.3 22.1 Murray Ridge
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Times−Bold,black+jLB -Gwhite@40 >> $ps << EOF
56.5 21.5 OMAN
63.5 28.5 P A K I S T A N
54.0 30.2 I R A N
74.0 22.0 I N D I A
49.0 22.0 SAUDI
49.0 21.3 ARABIA
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f13p,Helvetica,white+jLB >> $ps << EOF
61.0 15.5 ARABIAN
62.2 14.0 SEA
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,Times-Roman,black+jLB+a-300 -Gwhite@45 >> $ps << EOF
48.0 6.0 S O M A L I
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Times-Roman,red+jLB+a-270 -Gwhite@40 >> $ps << EOF
74.0 2.0 M  a  l  d  i  v  e  s
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Times−Bold,black+jLB -Gwhite@40 >> $ps << EOF
53.0 11.4 Socotra
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Times-Roman,black+jLB+a-333 -Gwhite@40 >> $ps << EOF
48.5 15.1 Y E M E N
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Helvetica,black+jLB+a-40 -Gwhite@35 >> $ps << EOF
58.8 6.7 C a r l s b e r g  R i d g e
EOF

# Add GMT logo
gmt logo -Dx6.2/-2.2+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y6.7c -N -O \
    -F+f12p,Palatino-Roman,black+jLB >> $ps << EOF
2.0 15.7 GEBCO global terrain model, 15 arc sec resolution grid
EOF

# Convert to image file using GhostScript
gmt psconvert Bathymetry_AS.ps -A0.5c -E720 -Tj -Z
