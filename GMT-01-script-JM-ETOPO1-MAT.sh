#!/bin/sh
# Purpose: shaded relief grid raster map from the ETOPO1 from 1 arc minute global data set (here: Middle America Trench)
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert
# Step-1. Generate a file
ps=BathymetryMAT.ps
# Step-2. GMT set up
gmt set FORMAT_GEO_MAP=dddF \
    MAP_FRAME_PEN=dimgray \
    MAP_FRAME_WIDTH=0.1c \
    MAP_TITLE_OFFSET=.7c \
    MAP_ANNOT_OFFSET=0.1c \
    MAP_TICK_PEN_PRIMARY=thinner,dimgray \
    MAP_GRID_PEN_PRIMARY=thin,white \
    MAP_GRID_PEN_SECONDARY=thinnest,white \
    FONT_TITLE=12p,Palatino-Roman,black \
    FONT_ANNOT_PRIMARY=7p,Helvetica,dimgray \
    FONT_LABEL=7p,Helvetica,dimgray \
# Step-3. Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults
# Step-4. Extract a subset of ETOPO1m for the Middle America area. format: -R0/360/-90/90
grdcut earth_relief_01m.grd -R263/278/7/17 -Gmat_relief.nc
# Step-5. Make color palette
gmt makecpt -Cgeo.cpt -V -T-7000/7000 > matocean.cpt
# Step-6. Make raster image
gmt grdimage mat_relief.nc -Cmatocean.cpt -R263/278/7/17 -JM6i -P -I+a15+ne0.75 -Xc -K > $ps
# Step-7. Add legend
gmt psscale -Dg260.5/7+w10.3c/0.4c+v+o0.3/0i+ml -Rmat_relief.nc -J -Cmatocean.cpt \
	--FONT_LABEL=8p,Helvetica,dimgray \
	--FONT_ANNOT_PRIMARY=5p,Helvetica,dimgray \
	-Baf+l"Topographic color scale" \
	-I0.2 -By+lm -O -K >> $ps
# Step-8. Add shorelines
gmt grdcontour mat_relief.nc -R -J -C500 -W0.2p -O -K >> $ps
# Step-9. Add grid with major and minor lines
gmt psbasemap -R -J \
    -Bpxg4f2a2 -Bpyg6f2a2 -Bsxg2 -Bsyg2 \
    -B+t"Bathymetry of the Guatemala Trench and coastal land topography" -O -K >> $ps
# Text names
gmt pstext -R -J -X0.0c -Y0.0c -N -O -K \
    -F+f10p,Palatino-Roman,white+jLB >> $ps << EOF
267.0 10.5 Cocos Plate
274.2 14.3 Carribean Plate
267.5 16.5 North American Plate
EOF
gmt pstext -R -J -X0.0c -Y0.0c -N -O -K \
    -F+jTL+f8p,Times-Roman,black+jLB -Gwhite@30 -Wthinnest >> $ps << EOF
274.4 11.5 Nicaragua
EOF
gmt pstext -R -J -X0.0c -Y0.0c -N -O -K \
    -F+jTL+f8p,Times-Roman,black+jLB+a-40 -Gwhite@30 -Wthinnest >> $ps << EOF
275.7 10.0 Costa Rica
EOF
gmt pstext -R -J -X0.0c -Y0.0c -N -O -K \
    -F+jTL+f8p,Times-Roman,black+jLB+a-340 -Gwhite@30 -Wthinnest >> $ps << EOF
270.0 15.1 Motagua Fault
EOF
gmt pstext -R -J -X0.0c -Y0.0c -N -O -K \
-F+jTL+f8p,Times-Roman,black+jLB+a-305 -Gwhite@30 -Wthinnest >> $ps << EOF
273.5 14.1 Guayape Fault
EOF
gmt pstext -R -J -X0.0c -Y0.0c -N -O -K \
    -F+jTL+f10p,Times-Roman,white=0.1p,black+jLB+a-330 >> $ps << EOF
264.7 15.5 Gulf of
264.7 15.0 Tehuantepec
EOF
# Text names
gmt pstext -R -J -X0.0c -Y0.0c -N -O -K \
    -F+jTL+f8p,Times-Roman,black+jLB+a-10 -Gwhite@30 -Wthinnest >> $ps << FIN
270.0 14.0 Guatemala-El Salvador
FIN
gmt pstext -R -J -X0.0c -Y0.0c -N -O -K \
    -F+jTL+f10p,Times-Roman,white=0.1p,black+jLB+a-350 >> $ps << EOF
271.0 12.7 Gulf of
271.3 12.5 Fonseca
EOF
gmt pstext -R -J -X0.0c -Y0.0c -N -O -K \
    -F+jTL+f10p,Times-Roman,white+jLB+a-25 >> $ps << EOF
264.5 10.0 P a c i f i c  O c e a n
EOF
# Text names
gmt pstext -R -J -X0.0c -Y0.0c -N -O -K \
    -F+jTL+f10p,Times-Roman,white+jLB+a-25 >> $ps << FIN
266.6 13.9 G  u  a  t  e  m  a  l  a
#266.5 14.0 M i d d l e
#269.5 12.7 A m e r i c a
FIN
# Text names
gmt pstext -R -J -X0.0c -Y0.0c -N -O -K \
    -F+jTL+f10p,Times-Roman,white+jLB+a-45 >> $ps << FIN
272.7 11.0 T  r  e  n  c  h
FIN
gmt pstext -R -J -X0.0c -Y0.0c -N -O -K \
    -F+jTL+f9p,Times-Roman,black+jLB+a-315 -Gwhite@30 -Wthinnest >> $ps << EOF
#263.4 13.1 Tehuantepec Ridge
275.4 7.3 Cocos
275.6 7.1 Ridge
EOF
gmt pstext -R -J -X0.0c -Y0.0c -N -O -K \
    -F+jTL+f10p,Times-Roman,white+jLB+a-312 >> $ps << EOF
263.2 12.9 Tehuantepec Ridge
EOF
# Step-10. Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=8p,Palatino-Roman,black \
    --MAP_TITLE_OFFSET=0.3c \
    -Lx13c/-1.2c+c50+w300k+l"Mercator Cylindrical Projection. Scale (km)"+f \
    -UBL/-15p/-40p -O -K >> $ps
# Step-10. Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=8p,Palatino-Roman,white \
    --MAP_TITLE_OFFSET=0.3c \
    -Tdx1.0c/1.0c+w0.3i+f2+l+o0.0c \
    -O -K >> $ps
# Step-11. Add GMT logo
gmt logo -Dx6.0/-2.2+o0.1i/0.1i+w2c -O -K >> $ps
# Step-12. Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y5.7c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
3.0 8.0 ETOPO1 Global Relief Model 1 arc min resolution grid
EOF
# Step-13. Convert to image file using GhostScript
gmt psconvert BathymetryMAT.ps -A0.2c -E720 -Tj -Z
