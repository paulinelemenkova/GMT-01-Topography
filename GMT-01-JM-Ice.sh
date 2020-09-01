#!/bin/sh
# Purpose: shaded relief grid raster map from the ETOPO1 from 1 arc minute global data set (here: Kuril-Kamchatka Trench)
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert

# GMT set up
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
# Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults

# Extract a subset of ETOPO1m for the Iceland area
# 13W25W
#grdcut ETOPO1_Ice_g_gmt4.grd -R335/347/63/67 -Gice_relief.nc
#grdcut ETOPO1_Ice_g_gmt4.grd -R335/347/63/67 -Gice_relief.nc
grdcut GEBCO_2019.nc -R335/347/63/67 -Gice_relief.nc
gdalinfo -stats ice_relief.nc
# Minimum=-1870.000, Maximum=2649.000

ps=BathymetryIce.ps
# Make color palette
gmt makecpt -Cgeo.cpt -V -T-1870/2649 > myocean.cpt

# Make raster image
gmt grdimage ice_relief.nc -Cmyocean.cpt -R335/347/63/67 -JM6i -P -I+a15+ne0.75 -Xc -K > $ps

# Add legend
gmt psscale -Dg333.1/63+w12.0c/0.15i+v+o0.3/0i+ml -R -J -Cmyocean.cpt \
	--FONT_LABEL=6p,Helvetica,dimgray \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,dimgray \
    --FONT_TITLE=6p,Helvetica,black \
	-Bg500f100a500+l"Color scale: geo [R=-1870/2649, H=0, C=RGB]" \
	-I0.2 -By+lm -O -K >> $ps
    
# Add shorelines
gmt grdcontour ice_relief.nc -R -J -C1000 -W0.1p -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P \
    -Ia/thinner,blue -Na -N1/thickest,red -W0.1p -Df -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_TITLE_OFFSET=0.7c \
    --FONT_ANNOT_PRIMARY=8p,Helvetica,dimgray \
    -Bpxg2f1a2 -Bpyg2f1a1 -Bsxg2 -Bsyg1 \
    -B+t"Topographic map of Iceland" -O -K >> $ps
    
# Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=8p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,dimgray \
    --MAP_TITLE_OFFSET=0.3c \
    -Tdx1.0c/1.3c+w0.3i+f2+l+o0.15i \
    -Lx5.3i/-0.5i+c50+w250k+l"Mercator projection. Scale (km)"+f \
    -UBL/-15p/-40p -O -K >> $ps
    
# Add GMT logo
gmt logo -Dx6.2/-2.2+o0.1i/0.1i+w2c -O -K >> $ps
# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y7.1c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
3.0 8.6 GEBCO global terrain model, 15 arc sec resolution grid
EOF

# Convert to image file using GhostScript
gmt psconvert BathymetryIce.ps -A0.2c -E720 -Tj -Z
