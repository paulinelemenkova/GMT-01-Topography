#!/bin/sh
# Purpose: shaded relief grid raster map from the ETOPO1 from 1 arc minute global data set (here: Kuril-Kamchatka Trench)
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert
# Step-1. Generate a file
ps=BathymetryTKT.ps
# Step-2. GMT set up
gmt set FORMAT_GEO_MAP=dddF \
    MAP_FRAME_PEN=dimgray \
    MAP_FRAME_WIDTH=0.1c \
    MAP_TITLE_OFFSET=0.8c \
    MAP_ANNOT_OFFSET=0.1c \
    MAP_TICK_PEN_PRIMARY=thinner,dimgray \
    MAP_GRID_PEN_PRIMARY=thinner,white \
    MAP_GRID_PEN_SECONDARY=thinner,white \
    FONT_TITLE=12p,Palatino-Roman,black \
    FONT_ANNOT_PRIMARY=7p,Helvetica,dimgray \
    FONT_LABEL=7p,Helvetica,dimgray \
# Step-3. Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults
# Step-4. Cut off the grid
#gmt grdcut topo15.grd -R140/195/-50/-5 -Gtkt_relief.nc -V
gmt grdcut earth_relief_01m.grd -R140/195/-50/-5 -Gtkt_relief.nc -V
gmt grdinfo @tkt_relief.nc
# Step-5. Make color palette
gmt makecpt -Cgeo.cpt -V -T-11000/4500 > myocean.cpt
# Step-6. Make raster image
gmt grdimage earth_relief_01m.grd -Cmyocean.cpt \
    -R140/195/-50/-5 \
    -JM6i -P -I+a15+ne0.75 -Xc -K > $ps
# Step-7. Add legend
gmt psscale -Dg131/-50+w14.8c/0.4c+v+o0.3/0i+ml \
    -Rtkt_relief.nc -J -Cmyocean.cpt \
	--FONT_LABEL=8p,Helvetica,dimgray \
	--FONT_ANNOT_PRIMARY=5p,Helvetica,dimgray \
	-Baf+l"Topographic color scale" \
	-I0.2 -By+lm -O -K >> $ps
# Step-8. Add shorelines
gmt grdcontour tkt_relief.nc -R -J -C1000 \
    -A2000+f6p,Palatino-Roman -Wthinnest -O -K >> $ps
# Step-9. Add grid
gmt psbasemap -R -J \
    -Bpxg20f10a10 -Bpyg20f10a10 -Bsxg10 -Bsyg10 \
    -B+t"Topographic contour map of the study area: Tonga and Kermadec trenches" -O -K >> $ps
# Step-9. Add texts
gmt pstext -R -J -N -O -K \
-F+f14p,Times-Roman,white+jLB >> $ps << EOF
149 -14 CORAL SEA
154 -42 TASMAN SEA
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,Times-Roman,black+jLB -Gwhite@30 >> $ps << EOF
178 -43.0 Chatham Rise
177.0 -19.5 Suva
173 -36 Auckland
174 -42 Wellington
144 -38 Melbourne
151 -32.5 Sydney
153 -26.5 Brisbane
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
145 -37 0.15c
174 -41 0.15c
174 -37 0.15c
151 -33 0.15c
153 -27 0.15c
178 -18 0.15c
EOF
gmt pstext -R -J -N -O -K \
-F+f8p,Times-Roman,black+jLB -Gwhite@30 >> $ps << EOF
174.5 -19 FIJI
172 -13 SAMOA
EOF
gmt pstext -R -J -N -O -K \
-F+f8p,Times-Roman,black+jLB+a-36 -Gwhite@30 >> $ps << EOF
163 -21.5 NEW CALEDONIA
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,Times-Roman,black+jLB+a-33 -Gwhite@30 >> $ps << EOF
154 -8 Solomon Is.
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,Times-Roman,black+jLB -Gwhite@30 >> $ps << EOF
141 -28 AUSTRALIA
141 -7 NEW GUINEA
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,Times-Roman,black+jLB+a-310 -Gwhite@30 >> $ps << EOF
168 -44 NEW ZEALAND
EOF
gmt pstext -R -J -N -O -K \
-F+f8p,Times-Roman,black+jLB+a-75 -Gwhite@30 >> $ps << EOF
168 -14 VANUATU
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,Times-Roman,black+jLB+a-290 -Gwhite@30>> $ps << EOF
183 -36 Kermadec Trench
187 -24 Tonga Trench
EOF
# Step-7. Study area
gmt psbasemap -R -J \
    -D177/-37/193/-13.5r -F+pthicker,yellow \
    -O -K >> $ps
# Step-10. Add scale, directional rose
#-Tdx13.0c/1.0c+w0.3i+f2+l+o0.15i
gmt psbasemap -R -J \
    --FONT=8p,Palatino-Roman,dimgray \
    --MAP_TITLE_OFFSET=0.3c \
    -Lx5.3i/-0.5i+c50+w1000k+l"Mercator projection. Scale (km)"+f \
    -UBL/-15p/-40p -O -K >> $ps
# Step-11. Add directional rose
gmt psbasemap -R -J \
    --FONT=8p,Palatino-Roman,white \
    --MAP_TITLE_OFFSET=0.2c \
    -Tdx14.3c/1.0c+w1.0+f2+l+o0.0c -O -K >> $ps
# Step-11. Add GMT logo
gmt logo -Dx6.2/-2.2+o0.1i/0.1i+w2c -O -K >> $ps
# Step-12. Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y5.8c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
#3.0 14.0 SRTM global terrain model, 15 arc-sec resolution grid
3.0 14.5 ETOPO1 global terrain model, 1 arc-min resolution grid
EOF
# Step-13. Convert to image file using GhostScript
gmt psconvert BathymetryTKT.ps -A0.2c -E720 -Tj -Z
