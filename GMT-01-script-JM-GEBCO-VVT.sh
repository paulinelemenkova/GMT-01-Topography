#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO from 15 arc sec global data set
# here: Vanuatu and Vityaz Trenches
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert
# Step-1. Generate a file
ps=BathymetryVVT_GEBCO.ps
# Step-2. GMT set up
gmt set FORMAT_GEO_MAP=dddF \
    MAP_FRAME_PEN=dimgray \
    MAP_FRAME_WIDTH=0.1c \
    MAP_TITLE_OFFSET=1c \
    MAP_ANNOT_OFFSET=0.1c \
    MAP_TICK_PEN_PRIMARY=thinner,dimgray \
    MAP_GRID_PEN_PRIMARY=thinner,white \
    MAP_GRID_PEN_SECONDARY=thinnest,white \
    FONT_TITLE=12p,Palatino-Roman,black \
    FONT_ANNOT_PRIMARY=8p,Helvetica,black \
    FONT_LABEL=8p,Helvetica,black \
    OBLIQUE_ANNOTATION 0 \
# Step-3. Overwrite defaults of GMTs
gmtdefaults -D > .gmtdefaults
# Step-4. Extract a subset of GEBCO for the Vanuatu Trench area  -JS170/-20/16c -JM16c
grdcut GEBCO_2019.nc -R145/200/-39/0 -Gvt_relief.nc
# grdcut earth_relief_01m.grd -R145/200/-39/0 -Gvt_relief.nc
# Step-5. Make color palette
gmt makecpt -Cgeo.cpt -V -T-11000/3000 > myocean.cpt
# Step-6. Make raster image
gmt grdimage vt_relief.nc -Cmyocean.cpt -R145/200/-39/0 -JM16c -P -I+a15+ne0.75 -Xc -K > $ps
# Step-7. Add color legend
gmt psscale -Dg136.3/-39+w12.2c/0.4c+v+o0.3/0i+ml -Rvt_relief.nc -J -Cmyocean.cpt \
	--FONT_LABEL=8p,Helvetica,dimgray \
	--FONT_ANNOT_PRIMARY=6p,Helvetica,black \
    --MAP_ANNOT_OFFSET=0.1c \
    --MAP_TITLE_OFFSET=0.1c \
-Baf+l"Topographic color scale. CPT 'geo' global relief [R=-8000/8000, H=0, C=RGB]" \
	-I0.2 -By+lm -O -K >> $ps
# Step-8. Add shorelines
gmt grdcontour vt_relief.nc -R -J -C2000 -W0.1p -O -K >> $ps
# Step-9. Add grid
gmt psbasemap -R -J \
    -Bpxg8f4a8 -Bpyg6f3a6 -Bsxg8 -Bsyg6 \
    -B+t"Topographic map of the Vanuatu Trench (New Hebrides) and Vityaz Trench" -O -K >> $ps
# Step-10. Add projection scale
gmt psbasemap -R -J \
    --FONT=9p,Palatino-Roman,dimgray \
    --MAP_TITLE_OFFSET=0.3c \
    -Lx14c/-0.5i+c50+w1000k+l"Mercator projection. Scale (km)"+f \
    -UBL/-5p/-40p -O -K >> $ps
# Step-10. Add directional rose
gmt psbasemap -R -J \
    --FONT=9p,Palatino-Roman,white \
    --MAP_TITLE_OFFSET=0.3c \
    -Tdx14.5c/1.5c+w0.3i+f2+l+o0.15i \
    -O -K >> $ps
# texts
gmt pstext -R -J -N -O -K \
-F+f9p,Times-Roman,black+jLB -Gwhite@20 -Wthinnest,darkbrown >> $ps << EOF
175 -38.5 NEW ZEALAND
145.3 -28.0 AUSTRALIA
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,Times-Roman,white+jLB >> $ps << EOF
149.5 -13.5 C O R A L
152.2 -15.5 S E A
184.8 -5.5 P A C I F I C
185.2 -9.2 O C E A N
172.5 -25.5 F I J I  S E A
152.5 -38.5 T A S M A N  S E A
EOF
# gmt psxy -R -J trench.gmt -Sf1.5c/0.2c+l+t -Wthick,yellow -Gyellow -O -K >> $ps
gmt pstext -R -J -N -O -K \
-F+f10p,Helvetica−Bold,white+jLB+a-290 >> $ps << EOF
182.4 -36 Kermadec Trench
186.5 -24 Tonga Trench
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,Helvetica−Bold,red+jLB+a-32 -Gwhite@30>> $ps << EOF
168 -7.5 Vityaz Trench
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,Helvetica−Bold,red+jLB+a-72 -Gwhite@40 >> $ps << EOF
166.8 -10.5 V a n u a t u  T r e n c h
EOF
gmt pstext -R -J -N -O -K \
-F+f8p,Times-Roman,black+jLB -Gwhite@30 >> $ps << EOF
176.0 -19.2 FIJI
189.0 -13.8 SAMOA
EOF
gmt pstext -R -J -N -O -K \
-F+f8p,Times-Roman,black+jLB+a-39 -Gwhite@30 >> $ps << EOF
164 -19.1 New Caledonia
EOF
# Step-7. Study area
gmt psbasemap -R -J \
-D162.5/-24/181.5/-6.0r -F+pthicker,yellow \
-O -K >> $ps
# Step-11. Add GMT logo
gmt logo -Dx6.5/-2.2+o0.1i/0.1i+w2c -O -K >> $ps
# Step-12. Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.0 -Y5.8c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
3.0 11.0 GEBCO DEM Global Relief Model 15 arc sec resolution grid
EOF
# Step-13. Convert to image file using GhostScript
gmt psconvert BathymetryVVT_GEBCO.ps -A0.5c -E720 -Tj -Z
# сетка с одинаковыми линиями
#    -Bxg4f2a4 -Byg4f2a4
