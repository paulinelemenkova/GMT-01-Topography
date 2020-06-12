#!/bin/sh
# Purpose: Bathymetric map of the Mariana Trench, grid raster map ETOPO1.
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, psscale, grdimage, grdcontour, psbasemap, pstext, logo, psconvert
# Unix prog: echo
# Step-1. Generate a file
ps=BathymetryPSB.ps
# Step-2. GMT set up
gmt set FORMAT_GEO_MAP=dddF \
    MAP_FRAME_PEN=dimgray \
    MAP_FRAME_WIDTH=0.1c \
    MAP_TITLE_OFFSET=1c \
    MAP_LABEL_OFFSET=3p \
    MAP_ANNOT_OFFSET=0.1c \
    MAP_TICK_PEN_PRIMARY=thinner,dimgray \
    MAP_GRID_PEN_PRIMARY=thin,white \
    MAP_GRID_PEN_SECONDARY=thinnest,white \
    FONT_TITLE=12p,Palatino-Roman,black \
    FONT_ANNOT_PRIMARY=7p,Helvetica,dimgray \
    FONT_LABEL=7p,Helvetica,dimgray
# Step-3. Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults
# Step-4. Extract a subset of ETOPO1m for the Mariana Trench area
#grdcut earth_relief_01m.grd -R120/152/4/35 -Gmt_relief.nc
grdcut GEBCO_2019.nc -R120/152/4/35 -Gmt_relief.nc
# Step-5. Make color palette
gmt makecpt -Cgeo.cpt -V -T-11000/1000 > myocean.cpt
# Step-6. Make raster image
gmt grdimage mt_relief.nc -Cmyocean.cpt -R120/152/4/35 -JY140/15/6.5i -P -I+a15 -K > $ps
# Step-7. Add legend
gmt psscale -Dg118.0/4+w16.0c/0.4c+v+o-2.0/0.0i+ml -Rmt_relief.nc -J -Cmyocean.cpt \
	--FONT_LABEL=8p,Helvetica,dimgray \
	--FONT_ANNOT_PRIMARY=5p,Helvetica,dimgray \
	-Baf+l"Topographic color scale" \
	-I0.2 -By+lm -O -K >> $ps
# Step-8. Add shorelines
gmt grdcontour mt_relief.nc -R -J -C1000 -W0.1p -O -K >> $ps
# Step-9. Add grid
gmt psbasemap -R -J \
    -Bpxg10f4a4 -Bpyg10f4a4 -Bsxg5 -Bsyg5 \
    -B+t"Bathymetric map of the Philippine Sea basin" -O -K >> $ps
# Step-10. Add scale, directional rose
gmt psbasemap -R -J \
    --MAP_TITLE_OFFSET=0.3c \
    --FONT_TITLE=8p,Palatino-Roman,dimgray \
    --MAP_ANNOT_OFFSET=0.1c \
    -Tdx2.2c/13.2c+w0.3i+f2+l+o0.15i \
    -Lx13.5c/-1.3c+c50+w1000k+l"Cylindrical Equal-Area Gall-Peters projection. Scale (km)"+f \
    -UBL/-15p/-40p -O -K >> $ps
# Step-11. Add text labels
echo "126 15 Philippine Trench" | gmt pstext -R -J -F+jTL+f10p,Times-Roman,white+a-70 -O -K >> $ps
echo "133 19 P h i l i p p i n e  S e a" | gmt pstext -R -J -F+jTL+f11p,Helvetica−Bold,white -O -K >> $ps
echo "146 28 Pacific Ocean" | gmt pstext -R -J -F+jBL+f11p,Helvetica−Bold,white -O -K >> $ps
echo "147.5 21 Mariana Trench" | gmt pstext -R -J -F+jBL+f10p,Times-Roman,white+a-80 -O -K >> $ps
# Step-12. Add subtitle
gmt pstext -R -J -X0.0c -Y0.0c -N -O -K \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
121.0 23.0 Bathymetry: GEBCO Global Relief Model 15 arc sec resolution grid
EOF
# Step-13. Add GMT logo
gmt logo -Dx5.0/-2.2+o0.1i/0.1i+w2c -O >> $ps
# Step-14. Convert to image file using GhostScript (portrait orientation, 720 dpi)
gmt psconvert BathymetryPSB.ps -A0.2c -E720 -Tj -P -Z
