#!/bin/sh
# Purpose: shaded relief grid raster map from the SRTM from 15 arc sec global data set (here: Manila Trench)
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert
# Step-1. Generate a file
ps=BathymetryMnT_SRTM.ps
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
    FONT_ANNOT_PRIMARY=7p,Helvetica,dimgray \
    FONT_LABEL=8p,Helvetica,dimgray \
# Step-3. Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults
# Step-4. Extract a subset of SRTM for the Manila Trench area
grdcut topo15.grd -R105/123/8/24 -Gman_relief.nc
# Step-5. Make color palette
gmt makecpt -Cgeo.cpt -V -T-10000/1000 > myocean.cpt
# Step-6. Make raster image
gmt grdimage man_relief.nc -Cmyocean.cpt -R105/123/8/24 -JM6i -P -I+a15+ne0.75 -Xc -K > $ps
# gmt grdimage SID_GRID_SRTM15+V2.0.nc -Crainbow.cpt -R140/170/40/60 -JM6i -P -I+a15+ne0.75 -Xc -K > $ps
# Step-7. Add legend
gmt psscale -Dg102/8+w14.3c/0.4c+v+o0.3/0i+ml -Rman_relief.nc -J -Cmyocean.cpt \
	--FONT_LABEL=8p,Helvetica,dimgray \
	--FONT_ANNOT_PRIMARY=5p,Helvetica,dimgray \
	-Baf+l"Topographic color scale" \
	-I0.2 -By+lm -O -K >> $ps
# Step-8. Add shorelines
gmt grdcontour man_relief.nc -R -J -C1000 -W0.1p -O -K >> $ps
# Step-9. Add grid
gmt psbasemap -R -J \
    -Bpxg8f2a2 -Bpyg6f3a2 -Bsxg4 -Bsyg3 \
    -B+t"Bathymetry of the South China Sea, Manila Trench and land topography" -O -K >> $ps
# Step-10. Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=9p,Palatino-Roman,dimgray \
    --MAP_TITLE_OFFSET=0.3c \
    -Tdx1.0c/13.3c+w0.3i+f2+l+o0.15i \
    -Lx5.3i/-0.5i+c50+w400k+l"Mercator projection. Scale (km)"+f \
    -UBL/-15p/-40p -O -K >> $ps
gmt pstext -R -J -N -O -K \
    -F+jTL+f10p,Times-Roman,black+jLB+a-328 >> $ps << EOF
107.0 19.5 Beibu Basin
EOF
gmt pstext -R -J -N -O -K \
    -F+jTL+f10p,Times-Roman,black+jLB+a-328 >> $ps << EOF
113.4 20.8 Pearl River
113.4 20.4 Mouth Basin
EOF
gmt pstext -R -J -N -O -K \
    -F+jTL+f10p,Times-Roman,black+jLB+a-323 >> $ps << EOF
109.5 17.7 Qiongdongnan
110.0 17.5 Basin
EOF
gmt pstext -R -J -N -O -K \
    -F+jTL+f10p,Times-Roman,black+jLB+a-350 -Gwhite@30 >> $ps << EOF
111.6 17.8 Xisha Trough
EOF
gmt pstext -R -J -N -O -K \
    -F+jTL+f10p,Times-Roman,black+jLB -Gwhite@30 >> $ps << EOF
114.0 22.1 Hong Kong
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
113.9 22.2 0.2c
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Times-Roman,black+jLB -Gwhite@30 >> $ps << EOF
113.0 23.5 Guangzhou
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
113.0 23.3 0.2c
EOF
gmt pstext -R -J -N -O -K \
    -F+jTL+f10p,Times-Roman,black+jLB -Gwhite@30 -Wthinnest >> $ps << EOF
120.2 23.3 Taiwan
EOF
gmt pstext -R -J -N -O -K \
    -F+jTL+f10p,Times-Roman,black+jLB -Gwhite@30 >> $ps << EOF
109.0 19.0 Hainan
EOF
gmt pstext -R -J -N -O -K \
    -F+jTL+f10p,Times-Roman,black+jLB -Gwhite@30 >> $ps << EOF
105.6 20.9 Hanoi
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
106.2 20.6 0.2c
EOF
gmt pstext -R -J -N -O -K \
    -F+jTL+f10p,Times-Roman,black+jLB -Gwhite@30 >> $ps << EOF
105.5 10.7 Ho Chi Minh
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
106.8 10.4 0.2c
EOF
gmt pstext -R -J -N -O -K \
    -F+jTL+f10p,Times-Roman,black+jLB -Gwhite@30 >> $ps << EOF
107.2 14.0 Central
107.2 13.6 Highlands
EOF
gmt pstext -R -J -N -O -K \
    -F+jTL+f10p,Times-Roman,black+jLB >> $ps << EOF
106.5 9.0 Nam Con Son
107.0 8.5 Basin
EOF
gmt pstext -R -J -N -O -K \
    -F+jTL+f10p,Times-Roman,black+jLB+a-87 -Gwhite@30  >> $ps << EOF
109.3 15.2 East Vietnam Transform
EOF
gmt pstext -R -J -N -O -K \
    -F+jTL+f10p,Times-Roman,black+jLB+a-88 -Gwhite@30  >> $ps << EOF
118.6 17.5 M a n i l a  T r e n c h
EOF
gmt pstext -R -J -N -O -K \
    -F+jTL+f10p,Times-Roman,black+jLB -Gwhite@30 >> $ps << EOF
116.0 21.0 Dongsha
EOF
gmt pstext -R -J -N -O -K \
    -F+jTL+f10p,Times-Roman,black+jLB -Gwhite@30 -Wthinnest >> $ps << EOF
120.5 17.0 Luzon
EOF
gmt pstext -R -J -N -O -K \
    -F+jTL+f10p,Times-Roman,black+jLB -Gwhite@30  >> $ps << EOF
120.1 15.5 Manila
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
120.5 16.0 0.2c
EOF
gmt pstext -R -J -N -O -K \
    -F+jTL+f10p,Times-Roman,black+jLB -Gwhite@30 >> $ps << EOF
116.5 11.4 Reed
116.5 11.0 Bank
EOF
gmt pstext -R -J -N -O -K \
    -F+jTL+f10p,Times-Roman,black+jLB -Gwhite@30 >> $ps << EOF
114.0 16.0 Macclesfield
114.0 15.6 Bank
EOF
gmt pstext -R -J -N -O -K \
    -F+jTL+f10p,Times-Roman,black+jLB+a-317 -Gwhite@30 >> $ps << EOF
116.2 9.0 N. Borneo Trough
EOF
gmt pstext -R -J -N -O -K \
    -F+jTL+f10p,Times-Roman,black+jLB+a-317 -Gwhite@30 >> $ps << EOF
117.5 9.2 Palawan Is.
EOF
# geology
#gmt psxy -R -J SC_luzon.txt -Wthin,red -O -K >> $ps
#gmt psxy -R -J SC_wphilippines.txt -Wthin,purple -O -K >> $ps
#gmt psxy -R -J SC_mindanao.txt -Wthin,magenta -O -K >> $ps
#gmt psxy -R -J trench.gmt -Sf1.5c/0.2c+l+t -Wthick,yellow -Gyellow -O -K >> $ps
#gmt psxy -R -J ophiolites.gmt -Sc0.2c -Gmagenta -Wthinnest -O -K >> $ps
#gmt psxy -R -J volcanoes.gmt -Sc0.2c -Gpurple -Wthinnest -O -K >> $ps
# Step-11. Add GMT logo
gmt logo -Dx6.2/-2.2+o0.1i/0.1i+w2c -O -K >> $ps
# Step-12. Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y5.0c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
3.0 15.0 SRTM Global Relief Model 15 arc sec resolution grid
EOF
# Step-13. Convert to image file using GhostScript
gmt psconvert BathymetryMnT_SRTM.ps -A0.2c -E720 -Tj -Z
# сетка с одинаковыми линиями
#    -Bxg4f2a4 -Byg4f2a4
