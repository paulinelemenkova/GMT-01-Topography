#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO from 15 arc sec global data set
# here: Hikurangi, Puysegur and Hjort trenches
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert

# Step-1. Extract a subset of GEBCO for the Hikurangi, Puysegur and Hjort trenches  -JS170/-20/16c -JM16c
grdcut GEBCO_2019.nc -R145/186/-62/-30 -Ghpt_relief.nc
#grdcut earth_relief_01m.grd -R145/186/-62/-30 -Ghpt_relief.nc
# Step-2. Make color palette
gmt makecpt -Cgeo.cpt -V -T-9000/3000 > myocean.cpt
#
# Step-1. Generate a file
ps=BathymetryHPT_GEBCO.ps
# Step-2. GMT set up
gmt set FORMAT_GEO_MAP=dddF \
    MAP_FRAME_PEN=dimgray \
    MAP_FRAME_WIDTH=0.1c \
    MAP_TITLE_OFFSET=1c \
    MAP_ANNOT_OFFSET=0.1c \
    MAP_TICK_PEN_PRIMARY=thinnest,dimgray \
    MAP_GRID_PEN_PRIMARY=thinnest,dimgray \
    MAP_GRID_PEN_SECONDARY=thinnest,dimgray \
    FONT_TITLE=12p,Palatino-Roman,black \
    FONT_ANNOT_PRIMARY=8p,Helvetica,black \
    FONT_LABEL=8p,Helvetica,black \
    MAP_ANNOT_OBLIQUE 10
# Step-3. Overwrite defaults of GMTs
gmtdefaults -D > .gmtdefaults
# Step-6. Make raster image
gmt grdimage hpt_relief.nc -Cmyocean.cpt -R145/186/-62/-30 -JM16c -P -I+a15+ne0.75 -Xc -K > $ps
# Step-7. Add color legend
gmt psscale -Dg137.0/-62+w18.8c/0.4c+v+o0.3/0i+ml -Rhpt_relief.nc -J -Cmyocean.cpt \
	--FONT_LABEL=11p,Helvetica,black \
	--FONT_ANNOT_PRIMARY=10p,Helvetica,black \
    --MAP_ANNOT_OFFSET=0.1c \
    --MAP_TITLE_OFFSET=0.1c \
    -Ba1000f200+l"Topographic color scale. CPT 'geo' global relief [R=-8000/8000, H=0, C=RGB]" \
	-I0.2 -By+lm -O -K >> $ps
# Step-8. Add shorelines
gmt grdcontour hpt_relief.nc -R -J -C2000 -W0.1p -O -K >> $ps
# Step-9. Add grid
gmt psbasemap -R -J \
    -Bpxg4f2a4 -Bpyg4f2a4 -Bsxg4 -Bsyg2 \
    --FONT_ANNOT_PRIMARY=10p,Helvetica,black \
    --FONT_TITLE=15p,Helvetica,black \
    --MAP_TITLE_OFFSET=1c \
    -B+t"Topographic map of the New Zealand, Hikurangi, Puysegur and Hjort trenches" -O -K >> $ps
# Step-10. Add projection scale
gmt psbasemap -R -J \
    --FONT=11p,Helvetica,black \
    --MAP_TITLE_OFFSET=0.3c \
    -Lx13.5c/-1.28c+c50+w800k+l"Mercator projection. Scale (km)"+f \
    -UBL/-5p/-40p -O -K >> $ps

# texts
gmt pstext -R -J -N -O -K \
-F+f11p,Helvetica−Bold,black+jLB -Gwhite@20 -Wthinnest,darkbrown >> $ps << EOF
146 -42 TASMAN
146 -32.0 AUSTRALIA
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,Helvetica−Bold,black+jLB -Gwhite@20 >> $ps << EOF
176.2 -36.2 North
176.2 -37.0 Island
171.7 -45 South
171.7 -45.8 Island
159.3 -55 Macquarie Island
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
159 -55 0.2c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,Helvetica−Bold,black+jLB+a-310 -Gwhite@20 >> $ps << EOF
161.2 -53 Macquarie Arc
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,Helvetica−Bold,black+jLB -Gwhite@20 >> $ps << EOF
170 -50 CAMPBELL
170 -50.7 PLATEAU
175 -43.5 CHATHAM RISE
167 -39 CHALLENGER
167 -39.8 PLATEAU
161 -57 Hjort
161 -57.7 Plateau
EOF
gmt pstext -R -J -N -O -K \
-F+f15p,Helvetica−Bold,white+jLB >> $ps << EOF
152.5 -38.5 T A S M A N  S E A
178 -54 P A C I F I C
178 -55 O C E A N
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,Helvetica−Bold,black+jLB+a-40 -Gwhite@20 >> $ps << EOF
147 -45.4 South Tasman
147 -46.2 Plateau
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,Helvetica−Bold,white+jLB+a-292 >> $ps << EOF
181.2 -36.3 Kermadec Trench
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,Helvetica−Bold,red+jLB+a-304 -Gwhite@20>> $ps << EOF
177.5 -42.2 Hikurangi Trench
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,Helvetica−Bold,red+jLB+a-308 -Gwhite@20>> $ps << EOF
158.5 -53.0 P u y s e g u r  T r e n c h
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,Helvetica−Bold,red+jLB+a-110 -Gwhite@20>> $ps << EOF
159 -56.0 Hjort
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,Helvetica−Bold,red+jLB+a-56 -Gwhite@20>> $ps << EOF
158.2 -58.0 Trench
EOF

# Step-11. Add GMT logo
gmt logo -Dx6.5/-2.2+o0.1i/0.1i+w2c -O -K >> $ps
# Step-12. Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.0 -Y12.3c -N -O \
    -F+f13p,Helvetica−Bold,black+jLB >> $ps << EOF
3.0 11.0 GEBCO DEM Global Relief Model 15 arc sec resolution grid
EOF
# Step-13. Convert to image file using GhostScript
gmt psconvert BathymetryHPT_GEBCO.ps -A1.0c -E720 -Tj -Z
