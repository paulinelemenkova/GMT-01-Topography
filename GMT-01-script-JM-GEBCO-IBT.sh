#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO from 15 arc sec global data set
# here: Izu-Bonin Trench
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert
# Step-1. Generate a file
ps=BathyIBT_GEBCO.ps
# Step-2. GMT set up
gmt set FORMAT_GEO_MAP=dddF \
    MAP_FRAME_PEN=dimgray \
    MAP_FRAME_WIDTH=0.1c \
    MAP_TITLE_OFFSET=1c \
    MAP_ANNOT_OFFSET=0.1c \
    MAP_TICK_PEN_PRIMARY=thinner,dimgray \
    MAP_GRID_PEN_PRIMARY=thin,white \
    MAP_GRID_PEN_SECONDARY=thinner,white \
    FONT_TITLE=12p,Palatino-Roman,black \
    FONT_ANNOT_PRIMARY=8p,Helvetica,black \
    FONT_LABEL=8p,Helvetica,black \
# Step-3. Overwrite defaults of GMTs
gmtdefaults -D > .gmtdefaults
# Step-4. Extract a subset of GEBCO for the Izu-Bonin Trench area
 grdcut GEBCO_2019.nc -R128/150/25/41 -Gibt_relief.nc
# grdcut earth_relief_01m.grd -R128/150/25/41 -Gibt_relief.nc
# Step-5. Make color palette
gmt makecpt -Cgeo.cpt -V -T-11500/3000 > myocean.cpt
# Step-6. Make raster image
gmt grdimage ibt_relief.nc -Cmyocean.cpt -R128/150/25/41 -JM16c -P -I+a15+ne0.75 -Xc -K > $ps
# Step-7. Add color legend
gmt psscale -Dg124.1/25+w14.0c/0.4c+v+o0.3/0i+ml -Ribt_relief.nc -J -Cmyocean.cpt \
	--FONT_LABEL=8p,Helvetica,dimgray \
	--FONT_ANNOT_PRIMARY=7p,Helvetica,black \
-Baf+l"Topographic color scale. CPT 'geo' global relief [R=-8000/8000, H=0, C=RGB]" \
	-I0.2 -By+lm -O -K >> $ps
# Step-8. Add shorelines
gmt grdcontour ibt_relief.nc -R -J -C2000 -W0.1p -O -K >> $ps
# Step-9. Add grid
gmt psbasemap -R -J \
    -Bpxg8f2a4 -Bpyg6f3a3 -Bsxg4 -Bsyg3 \
    -B+t"Geographic location of the Izu-Bonin Trench on the topographic map" -O -K >> $ps
# Step-10. Add projection scale
gmt psbasemap -R -J \
    --FONT=9p,Palatino-Roman,dimgray \
    --MAP_TITLE_OFFSET=0.3c \
    -Lx14c/-0.5i+c50+w400k+l"Mercator projection. Scale (km)"+f \
    -UBL/-5p/-40p -O -K >> $ps
# Step-10. Add directional rose
gmt psbasemap -R -J \
    --FONT=9p,Palatino-Roman,white \
    --MAP_TITLE_OFFSET=0.3c \
    -Tdx14.5c/1.5c+w0.3i+f2+l+o0.15i \
    -O -K >> $ps
# Rotated rectangle. kwargs: coords, direction degrees, x and y-dimension
gmt psxy -R -J -Sj1c -W1.5p,gold -O -K << EOF >> $ps
142.7 30.8 12 3 7.0
EOF
# texts
gmt pstext -R -J -N -O -K \
-F+f11p,Times-Roman,darkblue+jLB -Gwhite@40 >> $ps << EOF
133 40 SEA OF JAPAN
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,Times-Roman,WHITE+jLB >> $ps << EOF
145.8 35.5 PACIFIC OCEAN
EOF
gmt pstext -R -J -N -O -K \
-F+f8p,Palatino-Roman,black+jLB -Gwhite@40 >> $ps << EOF
128.1 36.5 KOREA
130 32.5 KYUSHU
134.0 35.0 HONSHU
135.8 29.5 SHIKOKU BASIN
EOF
gmt pstext -R -J -N -O -K \
-F+f8p,Palatino-Roman,black+jLB+a-80 -Gwhite@30 >> $ps << EOF
139.3 32.8 I  Z  U  -  B  O  N  I  N   A  R  C
EOF
gmt pstext -R -J -N -O -K \
-F+f8p,Palatino-Roman,black+jLB+a-325 -Gwhite@40>> $ps << EOF
137.4 35.7 J    A    P    A    N
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,Helvetica−Bold,gold+jLB+a-254 >> $ps << EOF
144.2 27.5 I  z  u - B  o  n  i  n
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,Helvetica−Bold,gold+jLB+a-265 >> $ps << EOF
142.8 31.9 T  r  e  n  c  h
EOF
# Step-11. Add GMT logo
gmt logo -Dx6.5/-2.2+o0.1i/0.1i+w2c -O -K >> $ps
# Step-12. Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.0 -Y7.5c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
3.0 11.0 GEBCO DEM Global Relief Model 15 arc sec resolution grid
EOF
# Step-13. Convert to image file using GhostScript
gmt psconvert BathyIBT_GEBCO.ps -A0.5c -E720 -Tj -Z
# сетка с одинаковыми линиями
#    -Bxg4f2a4 -Byg4f2a4
