#!/bin/sh
# Purpose: shaded relief grid raster map from the ETOPO1 from 1 arc minute global data set (here: Aleutian Trench)
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert
# Step-1. Generate a file
ps=BathymetryAT.ps
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
# Step-4. Extract a subset of ETOPO1m for the Aleutian Trench area. format: -R0/360/-90/90
grdcut earth_relief_01m.grd -R154/220/40/65 -Gat_relief.nc
# Step-5. Make color palette
gmt makecpt -Cgeo.cpt -V -T-8200/8000 > atocean.cpt
# Step-6. Make raster image
gmt grdimage at_relief.nc -Catocean.cpt -R154/220/40/65 -JM6i -P -I+a15+ne0.75 -Xc -K > $ps
# Step-7. Add color legend
gmt psscale -Dg142.5/40.1+w9.8c/0.4c+v+o0.3/0i+ml \
    -Rat_relief.nc -J -Catocean.cpt \
	--FONT_LABEL=8p,Helvetica,dimgray \
	--FONT_ANNOT_PRIMARY=5p,Helvetica,dimgray \
	-Baf+l"Topographic color scale" \
	-I0.2 -By+lm -O -K >> $ps
# Step-8. Add shorelines
gmt grdcontour at_relief.nc -R -J -C400 -W0.06p -O -K >> $ps
# Step-9. Add grid with major and minor lines
gmt psbasemap -R -J \
    -Bpxg12f6a12 -Bpyg5f5a5 -Bsxg6 -Bsyg5 \
    -B+t"Bathymetry of the Aleutian Trench and coastal land topography" -O -K >> $ps
# Step-10. Add scale
gmt psbasemap -R -J \
    --FONT=8p,Palatino-Roman,black \
    --MAP_TITLE_OFFSET=0.3c \
    -Lx5.3i/-0.5i+c50+w1000k+l"Mercator Cylindrical Projection. Scale (km)"+f \
    -UBL/-15p/-40p -O -K >> $ps
# Step-11. Add directional rose
gmt psbasemap -R -J \
    --FONT=8p,Palatino-Roman,white \
    --MAP_TITLE_OFFSET=0.2c \
    -Tdx14.0c/1.3c+w1.0+f2+l+o0.0c -O -K >> $ps
# Step-11. Add GMT logo
gmt logo -Dx6.2/-2.2+o0.1i/0.1i+w2c -O -K >> $ps
# Step-12. Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y5.2c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
3.0 8.0 ETOPO1 Global Relief Model 1 arc min resolution grid
EOF
# Step-13. Convert to image file using GhostScript
gmt psconvert BathymetryAT.ps -A0.2c -E720 -Tj -Z
