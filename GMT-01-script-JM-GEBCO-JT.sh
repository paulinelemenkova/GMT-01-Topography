#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO from 15 arc sec global data set
# here: Japan trench
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert
# Step-1. Generate a file
ps=BathyJT_GEBCO.ps
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
# Step-4. Extract a subset of GEBCO for the Japan trench area
 grdcut GEBCO_2019.nc -R128/150/30/46 -Gjt_relief.nc
# grdcut earth_relief_01m.grd -R128/150/30/46 -Gjt_relief.nc
# Step-5. Make color palette
gmt makecpt -Cgeo.cpt -V -T-11500/3000 > myocean.cpt
# Step-6. Make raster image
gmt grdimage jt_relief.nc -Cmyocean.cpt -R128/150/30/46 -JM16c -P -I+a15+ne0.75 -Xc -K > $ps
# Step-7. Add color legend
gmt psscale -Dg124.5/30+w15.0c/0.4c+v+o0.3/0i+ml -Rjt_relief.nc -J -Cmyocean.cpt \
	--FONT_LABEL=8p,Helvetica,dimgray \
	--FONT_ANNOT_PRIMARY=6p,Helvetica,black \
	-Baf+l"Topographic color scale" \
	-I0.2 -By+lm -O -K >> $ps
# Step-8. Add shorelines
gmt grdcontour jt_relief.nc -R -J -C2000 -W0.1p -O -K >> $ps
# Step-9. Add grid
gmt psbasemap -R -J \
    -Bpxg8f2a4 -Bpyg6f3a3 -Bsxg4 -Bsyg3 \
    -B+t"Topographic map of the Japan Trench region" -O -K >> $ps
# Step-10. Add projection scale
gmt psbasemap -R -J \
    --FONT=9p,Palatino-Roman,dimgray \
    --MAP_TITLE_OFFSET=0.3c \
    -Lx14c/-0.5i+c50+w500k+l"Mercator projection. Scale (km)"+f \
    -UBL/-5p/-40p -O -K >> $ps
# Step-10. Add directional rose
gmt psbasemap -R -J \
    --FONT=9p,Palatino-Roman,white \
    --MAP_TITLE_OFFSET=0.3c \
    -Tdx14.5c/1.5c+w0.3i+f2+l+o0.15i \
    -O -K >> $ps
# Step-7. Square of study area
#gmt psbasemap -R -J \
#    -D142/34/146/41r -F+pthicker,yellow+r \
#    -O -K >> $ps
# Rotated rectangle. kwargs: coords, direction degrees, x and y-dimension
gmt psxy -R -J -Sj1c -W1.5p,gold -O -K << EOF >> $ps
143.6 37.7 345 3 6.8
EOF
# texts
gmt pstext -R -J -N -O -K \
-F+f11p,Times-Roman,darkblue+jLB -Gwhite@30 >> $ps << EOF
133 40 SEA OF JAPAN
145.5 35.5 PACIFIC OCEAN
EOF
gmt pstext -R -J -N -O -K \
-F+f8p,Palatino-Roman,black+jLB -Gwhite@30 >> $ps << EOF
142 43.5 HOKKAIDO
130 32.5 KYUSHU
EOF
gmt pstext -R -J -N -O -K \
-F+f8p,Palatino-Roman,black+jLB+a-320 -Gwhite@40 >> $ps << EOF
138 35.8 H O N S H U
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,AvantGarde−Demi,gold+jLB+a-297 >> $ps << EOF
142.8 35.2 J  a  p  a  n
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,AvantGarde−Demi,gold+jLB+a-275 >> $ps << EOF
144.5 38.0 T  r  e  n  c  h
EOF
# Step-11. Add GMT logo
gmt logo -Dx6.5/-2.2+o0.1i/0.1i+w2c -O -K >> $ps
# Step-12. Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y8.5c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
3.0 11.0 GEBCO DEM Global Relief Model 15 arc sec resolution grid
EOF
# Step-13. Convert to image file using GhostScript
gmt psconvert BathyJT_GEBCO.ps -A0.2c -E720 -Tj -Z
# сетка с одинаковыми линиями
#    -Bxg4f2a4 -Byg4f2a4
