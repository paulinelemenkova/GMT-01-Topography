#!/bin/sh
# Purpose: Bathymetric map of the Philippine Sea basin: grid raster map GEBCO.
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, pstext, psxy, logo, psconvert
# Unix prog: echo
# Step-1. Generate a file
ps=BathymetryPSB.ps
# Step-2. GMT set up
gmt set FORMAT_GEO_MAP=dddF \
    MAP_FRAME_PEN=dimgray \
    MAP_FRAME_WIDTH=0.1c \
    MAP_TITLE_OFFSET=1.5c \
    MAP_ANNOT_OFFSET=0.1c \
    MAP_TICK_PEN_PRIMARY=thinner,dimgray \
    MAP_GRID_PEN_PRIMARY=thinest,white \
    MAP_GRID_PEN_SECONDARY=thinnest,white \
    MAP_LABEL_OFFSET=3p \
    FONT_TITLE=12p,Palatino-Roman,black \
    FONT_ANNOT_PRIMARY=7p,Palatino-Roman,dimgray \
    FONT_LABEL=7p,Palatino-Roman,dimgray \
# Step-3. Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults
# Extract a subset
#grdcut GEBCO_2019.nc -R120/152/0/35 -Gpsb_relief.nc
# Step-4. Extract a subset of GEBCO for the Philippine Sea basin
grdcut earth_relief_01m.grd -R120/152/0/35 -Gpsb_relief.nc
# Step-5. Make color palette
gmt makecpt -Cglobe.cpt -V -T-11000/1000 > myocean.cpt
# Step-6. Make raster image
gmt grdimage psb_relief.nc -Cmyocean.cpt -R120/152/0/35 -JPoly/6.5i -P -I+a15 -K > $ps
# Step-7. Add legend
gmt psscale -Dg119/0+w6.0i/0.15i+v+o-2.0/0.0i+ml -Rpsb_relief.nc -J -Cmyocean.cpt \
	-Baf+l"Topographic color scale" \
	-I0.2 -By+lm -O -K >> $ps
# Step-8. Add shorelines, title
gmt grdcontour psb_relief.nc -R -J -C1000 \
    -B+t"Bathymetric map of the Philippine Sea basin. Bathymetry: 15 arc sec GEBCO" -O -K >> $ps
# Step-9. Add grid
gmt psbasemap -R120/160/0/35 -JPoly/6.5i \
    --FONT_TITLE=8p,Palatino-Roman,black \
    --MAP_TITLE_OFFSET=0.3c \
    -Tdx2.5c/13c+w0.3i+f2+l+o0.15i \
    -Lx5.5i/-0.5i+c50+w1000k+l"Polyconic projection. Scale (km)"+f \
    -Bpxg8f2a4 -Bpyg8f2a4 -Bsxg4 -Bsyg4 \
    -UBL/-15p/-35p -O -K >> $ps
# Step-10. Add text labels
echo "126 15 Philippine Trench" | gmt pstext -R -J -F+jTL+f10p,Times-Roman,white+a-70 -O -K >> $ps
echo "132 20 Philippine Sea" | gmt pstext -R -J -F+f10p,Times-Roman,white -O -K >> $ps
echo "153 30 Pacific Ocean" | gmt pstext -R -J -F+f10p,Times-Roman,white -O -K >> $ps
echo "140 17.5 Mariana Trench" | gmt pstext -R -J -F+f10p,Times-Roman,white -O -K >> $ps
# Step-14. Add GMT logo
gmt logo -Dx6.2/-2.2+o0.1i/0.1i+w2c -O >> $ps
# Step-15. Convert to image file using GhostScript (portrait orientation, 720 dpi)
gmt psconvert BathymetryPSB.ps -A0.2c -E720 -Tj -P -Z
