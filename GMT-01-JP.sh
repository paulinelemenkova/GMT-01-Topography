#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO from 15 arc sec global data set
# here: Japan
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert
# Step-1. Generate a file

ps=Topo_JP.ps
# GMT set up
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
# Overwrite defaults of GMTs
gmtdefaults -D > .gmtdefaults

# Extract a subset of GEBCO for the Japan trench area
gmt grdcut GEBCO_2019.nc -R128/150/30/46 -Gjp_relief
# gmt grdcut ETOPO1_Ice_g_gmt4.grd -R128/150/30/46 -Gjp_relief


#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R11/32/-14/6 -JM6.5i -Dh -M -ECD > Congo.txt
#####################################################################
# Make color palette
gmt makecpt -Cgeo.cpt -V -T-11500/3000 > myocean.cpt
# Step-6. Make raster image
gmt grdimage jp_relief -Cmyocean.cpt -R128/150/30/46 -JM16c -P -I+a15+ne0.75 -Xc -K > $ps
# Step-7. Add color legend
gmt psscale -Dg124.5/30+w15.0c/0.4c+v+o0.3/0i+ml -Rjp_relief -J -Cmyocean.cpt \
	--FONT_LABEL=10p,0,black \
	--FONT_ANNOT_PRIMARY=8p,0,black \
	--Bg1000f100a500+l"Topographic color scale" \
	-I0.2 -By+lm -O -K >> $ps
# Step-8. Add shorelines
gmt grdcontour jp_relief -R -J -C2000 -W0.1p -O -K >> $ps
# Step-9. Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=wESN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    -Bpxg8f2a4 -Bpyg6f3a3 -Bsxg4 -Bsyg3 \
    -B+t"Topographic map of Japan" -O -K >> $ps
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
# Step-7. Texts
gmt pstext -R -J -N -O -K \
-F+f11p,Times-Roman,white+jLB >> $ps << EOF
133 41 SEA OF JAPAN
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
# Step-8. Add GMT logo
gmt logo -Dx6.5/-2.2+o0.1i/0.1i+w2c -O -K >> $ps
# Step-9. Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y8.4c -N -O \
    -F+f10p,0,black+jLB >> $ps << EOF
3.0 11.0 GEBCO DEM Global Relief Model 15 arc sec resolution grid
EOF
# Step-13. Convert to image file using GhostScript
gmt psconvert Topo_JP.ps -A0.2c -E720 -Tj -Z
