#!/bin/sh
# Purpose: shaded relief grid raster map from the ETOPO1 from 1 arc minute global data set (here: Peru-Chile Trench)
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert
# Step-1. Generate a file
ps=BathymetryPCT.ps
# Step-2. GMT set up
gmt set FORMAT_GEO_MAP=dddF \
    MAP_FRAME_PEN=dimgray \
    MAP_FRAME_WIDTH=0.1c \
    MAP_TITLE_OFFSET=1.0c \
    MAP_ANNOT_OFFSET=0.1c \
    MAP_TICK_PEN_PRIMARY=thinner,dimgray \
    MAP_GRID_PEN_PRIMARY=thin,white \
    MAP_GRID_PEN_SECONDARY=thinnest,white \
    FONT_TITLE=12p,Palatino-Roman,black \
    FONT_ANNOT_PRIMARY=8p,Helvetica,dimgray \
    FONT_LABEL=8p,Helvetica,dimgray \
# Step-3. Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults
# Step-4. Extract a subset of ETOPO1m for the Peru-Chile area. format: -R0/360/-90/90,
# here: 0°00S to -55°00S, 90 W to 60 W
grdcut earth_relief_01m.grd -R270/300/-55/0 -Gpct_relief.nc
# Step-5. Make color palette
gmt makecpt -Cgeo.cpt -V -T-8000/7000 > pctocean.cpt
# Step-6. Make raster image
gmt grdimage pct_relief.nc -Cpctocean.cpt -R270/300/-55/0 -JM4.5i -P -I+a15+ne0.75 -Xc -K > $ps
# Step-7. Add color legend
gmt psscale -Dg263.0/-55+w9.7i/0.4c+v+o0.3/0i+ml -Rpct_relief.nc -J -Cpctocean.cpt \
	--FONT_LABEL=9p,Helvetica,dimgray \
	--FONT_ANNOT_PRIMARY=7p,Helvetica,dimgray \
	-Baf+l"Topographic color scale" \
	-I0.2 -By+lm -O -K >> $ps
# Step-8. Add shorelines
gmt grdcontour pct_relief.nc -R -J -C1000 -W0.2p -O -K >> $ps
# Step-9. Add grid with major and minor lines
gmt psbasemap -R -J \
    -Bpxg8f4a8 -Bpyg10f5a4 -Bsxg4 -Bsyg5 \
    -B+t"Bathymetry of the Peru-Chile Trench and coastal land topography" -O -K >> $ps
# Step-10. Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=8p,Palatino-Roman,black \
    --MAP_TITLE_OFFSET=0.3c \
    -Lx9c/-1.2c+c50+w600k+l"Mercator Cylindrical Projection. Scale (km)"+f \
    -UBL/-10p/-40p -O -K >> $ps
# Step-10. Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=8p,Palatino-Roman,white \
    --MAP_TITLE_OFFSET=0.3c \
    -Tdx1.0c/1.0c+w0.3i+f2+l+o0.0c \
    -O -K >> $ps
# texts
gmt pstext -R -J -X0.0c -Y0.0c -N -O -K \
-F+f10p,Palatino-Roman,white+jLB+a-350 >> $ps << EOF
284.0 -25.0 Taltal Ridge
283.0 -26.5 Copiapo Ridge
276.0 -34.0 Juan Fernandez Ridge
EOF
gmt pstext -R -J -X0.0c -Y0.0c -N -O -K \
-F+f10p,Palatino-Roman,white+jLB+a-330 >> $ps << EOF
280.0 -21.0 Nazca FZ
EOF
gmt pstext -R -J -X0.0c -Y0.0c -N -O -K \
-F+f10p,Palatino-Roman,white+jTR+a-300 >> $ps << EOF
285.0 -33.5 O'Higgins Guyot
EOF
gmt pstext -R -J -X0.0c -Y0.0c -N -O -K \
-F+f12p,Palatino-Roman,black+jLB+a-65 -Gwhite@40 -Wthinnest >> $ps << EOF
276.0 -41.5 Chile Rise
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,Times-Roman,black+jLB+a-310 -Gwhite@40 -Wthinnest >> $ps << EOF
278.0 -19.0 Nazca Ridge
283.0 -24.5 Iquique Ridge
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,Times-Roman,yellow+jLB+a-45 >> $ps << EOF
289.0 -15.0 Central
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,Times-Roman,yellow+jLB+a-85 >> $ps << EOF
292.0 -19.0 Andes
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,Times-Roman,black+jLB -Gwhite@40 -Wthinnest >> $ps << EOF
271.0 -25.0 Easter Seamount Chain
EOF
gmt pstext -R -J -N -O -K \
-F+f14p,Times-Roman,black+jLB -Gwhite@30 -Wthinnest >> $ps << EOF
290.0 -6.0 South America
EOF
gmt pstext -R -J -N -O -K \
-F+f14p,Times-Roman,yellow+jLB >> $ps << EOF
275.0 -29.0 Nazca Plate
275.0 -49.0 Antarctic Plate
EOF
# Step-11. Add GMT logo
gmt logo -Dx4.0/-2.2+o0.1i/0.1i+w2c -O -K >> $ps
# Step-12. Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y20.5c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
1.0 8.0 ETOPO1 Global Relief Model 1 arc min resolution grid
EOF
# Step-13. Convert to image file using GhostScript
gmt psconvert BathymetryPCT.ps -A0.5c -E720 -Tj -Z
