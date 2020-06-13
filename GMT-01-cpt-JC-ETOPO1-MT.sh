#!/bin/sh
# Purpose: Bathymetric map of the Mariana Trench, grid raster map ETOPO1.
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, psscale, grdimage, grdcontour, psbasemap, pstext, logo, psconvert
# Unix prog: echo
# Step-1. Generate a file
ps=Bathy_JC_MT.ps
# Step-2. GMT set up
gmt set FORMAT_GEO_MAP dddF \
    MAP_FRAME_TYPE fancy \
    MAP_FRAME_PEN dimgray \
    MAP_FRAME_WIDTH 0.1c \
    MAP_TITLE_OFFSET 1c \
    MAP_LABEL_OFFSET 3p \
    MAP_ANNOT_OFFSET 0.1c \
    MAP_TICK_PEN_PRIMARY thinner,dimgray \
    MAP_GRID_PEN_PRIMARY thin,white \
    MAP_GRID_PEN_SECONDARY thinnest,white \
    FONT_TITLE 12p,Palatino-Roman,black \
    FONT_ANNOT_PRIMARY 7p,Palatino-Roman,dimgray \
    FONT_LABEL 7p,Palatino-Roman,dimgray
# Step-3. Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults
# Step-4. Extract a subset of ETOPO1m for the Mariana Trench area
grdcut earth_relief_01m.grd -R120/160/5/30 -Gmt_relief2.nc
# Step-5. Make color palette
#gmt makecpt -Cglobe.cpt -V -T-11000/2000 > myocean2.cpt
# makecpt --help
gmt makecpt -Cgeo.cpt -V -T-11000/2000 > myocean2.cpt
#gmt makecpt -Cearth.cpt -V -T-11000/2000 > myocean2.cpt
#gmt makecpt -Cibcso.cpt -V -T-11000/2000 > myocean2.cpt
#gmt makecpt -Cbathy.cpt -V -T-11000/2000 > myocean2.cpt
#gmt makecpt -Cterra.cpt -V -T-11000/2000 > myocean2.cpt
#gmt makecpt -Crelief.cpt -V -T-11000/2000 > myocean2.cpt
#gmt makecpt -Ctopo.cpt -V -T-11000/2000 > myocean2.cpt
#gmt makecpt -Cetopo1.cpt -V -T-11000/2000 > myocean2.cpt
#gmt makecpt -Cworld.cpt -V -T-11000/2000 > myocean2.cpt
#gmt makecpt -Cpanoply.cpt -V -T-11000/2000 > myocean2.cpt
# Step-6. Make raster image
gmt grdimage mt_relief2.nc -Cmyocean2.cpt -R120/160/5/30 -JC140/17/6i -P -I+a15 -K > $ps
# Step-7. Add legend
gmt psscale -Dg120/4+w10.0c/0.4c+v+o-1.5/0.5c+ml -R -J -Cmyocean2.cpt \
	--FONT_LABEL=8p,Helvetica,dimgray \
	--FONT_ANNOT_PRIMARY=5p,Helvetica,dimgray \
	-Baf+l"Topographic color scale" \
	-I0.2 -By+lm -O -K >> $ps
# Step-8. Add shorelines
gmt grdcontour mt_relief2.nc -R -J -C1000 -O -K >> $ps
# Step-9. Add grid
gmt psbasemap -R -J \
    -Bpxg10f4a4 -Bpyg10f4a4 -Bsxg5 -Bsyg5 \
    -B+t"Geographic location of the Mariana Trench" -O -K >> $ps
# Step-10. Add scale, directional rose
gmt psbasemap -R -J \
    --MAP_TITLE_OFFSET=0.2c \
    --FONT_TITLE=8p,Palatino-Roman,dimgray \
    --MAP_ANNOT_OFFSET=0.1c \
    -Tdx2.0c/9.0c+w0.3i+f2+l+o0.0c \
    -Lx13.0c/-1.3c+c50+w1500k+l"Cassini Transverse Cylindrical Projection. Scale (km)"+f \
    -UBL/-15p/-40p -O -K >> $ps
# Step-11. Add text labels
echo "126 15 Philippine Trench" | gmt pstext -R -J -F+jTL+f10p,Times-Roman,white+a-70 -O -K >> $ps
echo "133 19 Philippine Sea" | gmt pstext -R -J -F+f10p,Times-Roman,white -O -K >> $ps
echo "153 28 Pacific Ocean" | gmt pstext -R -J -F+f10p,Times-Roman,white -O -K >> $ps
echo "147.5 21 Mariana Trench" | gmt pstext -R -J -F+jBL+f10p,Times-Roman,white+a-80 -O -K >> $ps
# Step-12. Add subtitle
gmt pstext -R -J -X0.0c -Y1.0c -N -O -K \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
124.0 30.0 Bathymetry: ETOPO1 Global Relief Model 1 arc min resolution grid
EOF
# Step-13. Add GMT logo
gmt logo -Dx6.5/-3.0+o0.1i/0.1i+w2c -O >> $ps
# Step-14. Convert to image file using GhostScript (portrait orientation, 720 dpi)
gmt psconvert Bathy_JC_MT.ps -A0.2c -E720 -Tj -P -Z
