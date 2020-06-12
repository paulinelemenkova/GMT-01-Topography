#!/bin/sh
# Purpose: shaded relief grid raster map from the ETOPO1 from 1 arc minute global data set (here: South China Sea)
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert
# Step-1. Generate a file
ps=BathymetrySC.ps
# Step-2. GMT set up
gmt set FORMAT_GEO_MAP=dddF \
    MAP_FRAME_PEN=dimgray \
    MAP_FRAME_WIDTH=0.1c \
    MAP_TITLE_OFFSET=1.0c \
    MAP_ANNOT_OFFSET=0.1c \
    MAP_TICK_PEN_PRIMARY=thinner,dimgray \
    MAP_GRID_PEN_PRIMARY=thinnest,snow4 \
    MAP_GRID_PEN_SECONDARY=thinnest,snow4 \
    FONT_TITLE=12p,Palatino-Roman,black \
    FONT_ANNOT_PRIMARY=7p,Helvetica,dimgray \
    FONT_LABEL=7p,Helvetica,dimgray \
# Step-3. Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults
# Step-4. Extract a subset of ETOPO1m for the South China Sea area. format: -R0/360/-90/90
grdcut earth_relief_01m.grd -R99/122/2/23 -Gscs_relief.nc
# Step-5. Make color palette
gmt makecpt -Cgeo.cpt -V -T-6000/6000 > atocean.cpt
# Step-6. Make raster image
gmt grdimage scs_relief.nc -Catocean.cpt -R99/122/2/23 -JM6i -P -I+a15+ne0.75 -Xc -K > $ps
# Step-7. Add color legend
gmt psscale -Dg95/2+w14.3c/0.4c+v+o0.3/0i+ml \
    -Rat_relief.nc -J -Catocean.cpt \
	--FONT_LABEL=8p,Helvetica,dimgray \
	--FONT_ANNOT_PRIMARY=5p,Helvetica,dimgray \
	-Baf+l"Topographic color scale" \
	-I0.2 -By+lm -O -K >> $ps
# Step-8. Add shorelines
gmt grdcontour at_relief.nc -R -J -C400 -W0.08p -O -K >> $ps
# Step-9. Add grid with major and minor lines
gmt psbasemap -R -J \
    -Bpxg4f3a3 -Bpyg6f5a3 -Bsxg4 -Bsyg3 \
    -B+t"Bathymetry of the South China Sea and coastal land topography" -O -K >> $ps
# Step-10. Add scale
gmt psbasemap -R -J \
    --FONT=8p,Palatino-Roman,black \
    --MAP_TITLE_OFFSET=0.3c \
    -Lx13c/-1.2c+c50+w500k+l"Mercator Cylindrical Projection. Scale (km)"+f \
    -UBL/-15p/-40p -O -K >> $ps
# Step-11. Add directional rose
gmt psbasemap -R -J \
    --FONT=8p,Palatino-Roman,white \
    --MAP_TITLE_OFFSET=0.2c \
    -Tdx14.1c/1.1c+w1.0+f2+l+o0.0c -O -K >> $ps
# Step-12. Add text
gmt pstext -R -J -N -O -K \
-F+f14p,Palatino-Roman,white+jLB >> $ps << EOF
112.5 12.8 South China Sea
EOF
# Step-13. Add GMT logo
gmt logo -Dx6.2/-2.2+o0.1i/0.1i+w2c -O -K >> $ps
# Step-14. Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y7.8c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
3.0 11.0 ETOPO1 Global Relief Model 1 arc min resolution grid
EOF
# Step-15. Convert to image file using GhostScript
gmt psconvert BathymetrySC.ps -A0.2c -E720 -Tj -Z
