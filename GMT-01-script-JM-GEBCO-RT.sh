#!/bin/sh
# Purpose: shaded relief grid raster map from the ETOPO1 from 1 arc minute global data set (here: Ryukyu Trench)
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert
# Step-1. Generate a file
ps=BathymetryRT_GEBCO.ps
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
    FONT_LABEL=7p,Helvetica,dimgray \
# Step-3. Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults
# Step-5. Make color palette
gmt makecpt -Cgeo.cpt -V -T-8000/1000 > myocean.cpt
# Step-6. Make raster image
gmt grdimage GEBCO_2019.nc -Cmyocean.cpt -R120/134/20/33 -JM6i -P -I+a15+ne0.75 -Xc -K > $ps
# gmt grdimage GEBCO_2019_SID.nc -Cmyocean.cpt -R140/170/40/60 -JM6i -P -I+a15+ne0.75 -Xc -K > $ps
# Step-7. Add legend
gmt psscale -Dg117.5/20+w16.0c/0.4c+v+o0.3/0i+ml -R120/134/20/33 -J -Cmyocean.cpt \
	--FONT_LABEL=8p,Helvetica,dimgray \
	--FONT_ANNOT_PRIMARY=6p,Helvetica,black \
	-Baf+l"Topographic color scale" \
	-I0.2 -By+lm -O -K >> $ps
# Step-8. Add shorelines
gmt grdcontour GEBCO_2019.nc -R -J -C700 -W0.1p -O -K >> $ps
# Step-9. Add grid
gmt psbasemap -R -J \
    -Bpxg4f2a2 -Bpyg4f4a2 -Bsxg2 -Bsyg2 \
    -B+t"Bathymetry of the Ryukyu Trench and coastal land topography" -O -K >> $ps
# Step-10. Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=10p,Palatino-Roman,black \
    --MAP_TITLE_OFFSET=0.3c \
    -Tdx1.0c/14.3c+w0.3i+f2+l+o0.15i \
    -Lx13c/-1.3c+c50+w300k+l"Mercator projection. Scale (km)"+f \
    -UBL/-15p/-40p -O -K >> $ps
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Times-Roman,black+jLB -Gwhite@30 >> $ps << EOF
120.5 23.6 Taiwan
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,Times-Roman,black+jLB+a-30 -Gwhite@30 >> $ps << EOF
129.0 29.5 Tokara Strait
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,Times-Roman,black+jLB+a-330 -Gwhite@30 >> $ps << EOF
124.0 25.0 Okinawa
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,Times-Roman,black+jLB+a-310 -Gwhite@30 >> $ps << EOF
126.3 27.0 Trough
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Times-Roman,black+jLB -Gwhite@30 >> $ps << EOF
130.5 32.5 Kyushu
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f13p,Times-Roman,blue+jLB>> $ps << EOF
123.0 29.0 E a s t  C h i n a  S e a
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f13p,Times-Roman,white+jLB+a-335 >> $ps << EOF
125.0 22.8 R y u k y u
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f13p,Times-Roman,white+jLB+a-315 >> $ps << EOF
128.9 25.2 T r e n c h
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,Times-Roman,black+jLB+a-330 -Gwhite@30 >> $ps << EOF
125.0 23.8 R y u k y u
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,Times-Roman,black+jLB+a-322 -Gwhite@30 >> $ps << EOF
127.0 25.0 I s l a n d s
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f13p,Times-Roman,white+jLB >> $ps << EOF
129.5 22.5 P h i l i p p i n e  S e a
EOF
# Step-11. Add GMT logo
gmt logo -Dx6.2/-2.2+o0.1i/0.1i+w2c -O -K >> $ps
# Step-12. Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y6.7c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
3.0 15.0 GEBCO global terrain model, 15 arc-sec resolution grid
EOF
# Step-13. Convert to image file using GhostScript
gmt psconvert BathymetryRT_GEBCO.ps -A0.5c -E720 -Tj -Z
# сетка с одинаковыми линиями
#    -Bxg4f2a4 -Byg4f2a4
