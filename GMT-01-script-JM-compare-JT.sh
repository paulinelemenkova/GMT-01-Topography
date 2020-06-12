#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO from 15 arc sec global data set
# here: Japan trench
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert
# Step-2. GMT set up
gmt set FORMAT_GEO_MAP=dddF \
    MAP_FRAME_PEN=dimgray \
    MAP_FRAME_WIDTH=0.1c \
    MAP_TITLE_OFFSET=1.0c \
    MAP_ANNOT_OFFSET=0.1c \
    MAP_TICK_PEN_PRIMARY=thinner,dimgray \
    MAP_GRID_PEN_PRIMARY=thinner,white \
    MAP_GRID_PEN_SECONDARY=thinnest,white \
    FONT_TITLE=12p,Palatino-Roman,black \
    FONT_ANNOT_PRIMARY=6p,Helvetica,black \
    FONT_LABEL=6p,Helvetica,black \
# Step-3. Overwrite defaults of GMTs
gmtdefaults -D > .gmtdefaults
# Step-5. Make color palette
gmt makecpt -Cgeo.cpt -V -T-11500/3000 > myocean.cpt
# Step-4. Extract subsets for the Japan trench area
grdcut GEBCO_2019.nc -R140/144/33/37 -Gjt_compare1.nc
grdcut topo15.grd -R140/144/33/37 -Gjt_compare2.nc
grdcut earth_relief_01m.grd -R140/144/33/37 -Gjt_compare3.nc
grdcut earth_relief_05m.grd -R128/150/30/46 -Gjt_compare4.nc
#
# Step-1. Generate a file
ps=BathyJT_compare.ps
#
# 1. GEBCO
# Make raster image
gmt grdimage jt_compare1.nc -Cmyocean.cpt -R140/144/33/37 -JM6c -Y13.0c \
    -I+a15+ne0.75 -Xc -K > $ps
# Add shorelines
gmt grdcontour jt_compare1.nc -R -J -C500 \
    -A1000+f6p,Helvetica,black -T -W0.2p,white \
    -O -K >> $ps
# Add grid
gmt psbasemap -R -J \
    -Bpxg1f2a1 -Bpyg1f2a1 -Bsxg1 -Bsyg1 -O -K >> $ps
#
# 2. SRTM
# Make raster image
gmt grdimage jt_compare2.nc -Cmyocean.cpt -R140/144/33/37 -JM6c -X8.0c \
    -I+a15+ne0.75 -O -K >> $ps
# Add shorelines
gmt grdcontour jt_compare2.nc -R -J -C500 \
    -A1000+f6p,Helvetica,black -T -W0.2p,white \
    -O -K >> $ps
# Add grid
gmt psbasemap -R -J \
    -Bpxg1f2a1 -Bpyg1f2a1 -Bsxg1 -Bsyg1 -O -K >> $ps
#
# 3. ETOPO1
# Make raster image
gmt grdimage jt_compare3.nc -Cmyocean.cpt -R140/144/33/37 -JM6c -X-8.0c -Y-9.0c \
    -I+a15+ne0.75 -O -K >> $ps
# Add shorelines
gmt grdcontour jt_compare3.nc -R -J -C500 \
    -A1000+f6p,Helvetica,black -T -W0.2p,white \
    -UBL/-5p/-40p -O -K >> $ps
# Add grid
gmt psbasemap -R -J \
    -Bpxg1f2a1 -Bpyg1f2a1 -Bsxg1 -Bsyg1 -O -K >> $ps
#
# 4. ETOPO5
# Make raster image
gmt grdimage jt_compare4.nc -Cmyocean.cpt -R140/144/33/37 -JM6c -X8.0c \
    -I+a15+ne0.75 -O -K >> $ps
# Add shorelines
gmt grdcontour jt_compare4.nc -R -J -C500 \
    -A1000+f6p,Helvetica,black -T -W0.2p,white \
    -O -K >> $ps
# Add grid
gmt psbasemap -R -J \
-Bpxg1f2a1 -Bpyg1f2a1 -Bsxg1 -Bsyg1 -O -K >> $ps
#
# Add projection scale
gmt psbasemap -R -J \
    --FONT=9p,Palatino-Roman,dimgray \
    --MAP_TITLE_OFFSET=0.3c \
    -Lx4c/-0.5i+c50+w200k+l"Mercator projection. Scale (km)"+f \
    -O -K >> $ps
# Add GMT logo
gmt logo -Dx0.0/-2.2+o-2.0c/0.1i+w2c -O -K >> $ps
# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X-9.0c -Y7.5c -N -O \
    -F+f10p,Helvetica-Narrow-Bold,black+jLB >> $ps << EOF
1.0 14.0 GEBCO
9.0 14.0 SRTM
1.0 0.7 ETOPO1
9.0 0.7 ETOPO5
1.0 15.0 Comparison of the topographic data resolution: selected southern fragment of the Japan Trench
EOF
# Convert to image file using GhostScript
gmt psconvert BathyJT_compare.ps -A1.0c -E720 -Tj -Z
