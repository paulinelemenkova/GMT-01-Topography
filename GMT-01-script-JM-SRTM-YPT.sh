#!/bin/sh
# Purpose: shaded relief grid raster map from the SRTM from 1 arc minute global data set
# here: Yap - Palau trenches
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert
# Step-1. Generate a file
ps=BathyYPT_SRTM.ps
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
    FONT_ANNOT_PRIMARY=8p,Helvetica,black \
    FONT_LABEL=8p,Helvetica,black \
# Step-3. Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults
# Step-4. Extract a subset of SRTM for the Yap and Palau trenches area
grdcut topo15.grd -R116/145/-6/20 -Gypt_relief.nc
# Step-5. Make color palette
gmt makecpt -Cgeo.cpt -V -T-11500/3000 > myocean.cpt
# Step-6. Make raster image
gmt grdimage ypt_relief.nc -Cmyocean.cpt -R116/145/-6/20 -JM16c -P -I+a15+ne0.75 -Xc -K > $ps
# Step-7. Add color legend
gmt psscale -Dg111.5/-6+w14.2c/0.4c+v+o0.3/0i+ml -Rypt_relief.nc -J -Cmyocean.cpt \
	--FONT_LABEL=8p,Helvetica,dimgray \
	--FONT_ANNOT_PRIMARY=6p,Helvetica,black \
	-Baf+l"Topographic color scale" \
	-I0.2 -By+lm -O -K >> $ps
# Step-8. Add shorelines
gmt grdcontour ypt_relief.nc -R -J -C1000 -W0.1p -O -K >> $ps
# Step-9. Add grid
gmt psbasemap -R -J \
    -Bpxg8f2a4 -Bpyg6f3a3 -Bsxg4 -Bsyg3 \
    -B+t"Topographic map of the Yap and Palau trenches region" -O -K >> $ps
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
# Step-7. Square of study area
gmt psbasemap -R -J \
    -D132/4/140/12r -F+pthicker,yellow \
    -O -K >> $ps
# texts
gmt pstext -R -J -N -O -K \
-F+f8p,Palatino-Roman,black+jLB -Gwhite@30 >> $ps << EOF
116.5 1.5 KALIMANTAN
119 -2.0 SULAWESI
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,Palatino-Roman,black+jLB -Gwhite@20 >> $ps << EOF
121 12.0 PHILIPPINES
137 -4.0 PAPUA NEW GUINEA
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,Times-Roman,darkblue+jLB -Gwhite@30 >> $ps << EOF
128.5 13.5 PHILIPPINE SEA
136 18.5 P A C I F I C  O C E A N
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,Times-Roman,darkblue+jLB -Gwhite@30 >> $ps << EOF
120.5 3.5 CELEBES SEA
118.5 8 SULU SEA
117 17 SOUTH
117 16.4 CHINA
117 15.8 SEA
127 -5 BANDA SEA
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,Palatino-Roman,red+jLB+a-308 -Gwhite@30 >> $ps << EOF
137.7 6.8 Yap Trench
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,Palatino-Roman,red+jLB+a-310 -Gwhite@30 >> $ps << EOF
133.5 4.5 Palau Trench
EOF
# Step-11. Add GMT logo
gmt logo -Dx6.5/-2.2+o0.1i/0.1i+w2c -O -K >> $ps
# Step-12. Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y8.0c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
3.0 11.0 SRTM DEM Global Relief Model 15 arc sec resolution grid
EOF
# Step-13. Convert to image file using GhostScript
gmt psconvert BathyYPT_SRTM.ps -A0.2c -E720 -Tj -Z
# сетка с одинаковыми линиями
#    -Bxg4f2a4 -Byg4f2a4
