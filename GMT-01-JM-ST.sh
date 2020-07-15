#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO dataset (here: Indian Ocean, Sunda Trench)
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
    FONT_LABEL=7p,Helvetica,dimgray
# Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults

grdcut GEBCO_2019.nc -R90/130/-20/10 -Gst_relief.nc
#grdcut ETOPO1_Ice_g_gmt4.grd -R90/130/-20/10 -Gst_relief.nc

gdalinfo st_relief.nc -stats
# Minimum=-9848.000, Maximum=3816.000
# Make color palette
# makecpt --help
gmt makecpt -Cgeo.cpt -V -T-9848/3816 > myocean.cpt

# Generate a file
ps=Bathymetry_ST.ps
# Make raster image
gmt grdimage st_relief.nc -Cmyocean.cpt -R90/130/-20/10 -JM6i -P -I+a15+ne0.75 -Xc -K > $ps
#gmt grdimage st_relief.nc -Cmyocean.cpt -R90/130/-20/10 -JA110/-5/15/6i -P -I+a15+ne0.75 -Xc -K > $ps


# Add grid
gmt psbasemap -R -J \
    -Bpx10f5a5 -Bpyg10f5a5 -Bsxg5 -Bsyg5 \
    --MAP_TITLE_OFFSET=0.8c \
    --FONT_ANNOT_PRIMARY=7p,Helvetica,black \
    -B+t"Topographic map of the Sunda Trench region, Indian Ocean" -O -K >> $ps
    
# Add shorelines
gmt grdcontour st_relief.nc -R -J -C1000 -W0.1p -O -K >> $ps
    
# Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=8p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=8p,Helvetica,black \
    --MAP_TITLE_OFFSET=0.3c \
    -Lx13.0c/-1.3c+c50+w800k+l"Mercator projection. Scale: km"+f \
    -UBL/-5p/-40p -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P \
    -Ia/thinnest,blue -Na -N1/thinner,red -W0.1p -Df -O -K >> $ps

# Add legend
gmt psscale -Dg85/-20+w11.4c/0.4c+v+o0.3/0i+ml -R -J -Cmyocean.cpt \
    --FONT_LABEL=6p,Helvetica,dimgray \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,black \
    -Baf+l"Color scale: geo global bathymetry/topography relief [R=-5119/3505, H=0, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps

# Texts
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,Helvetica,black+jLB -Gwhite@30 >> $ps << EOF
112 1 Kalimantan
109 -7.8 Java
119 -2 Sulavesi
104 0.5 Singapore
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,Helvetica,black+jLB+a-46 -Gwhite@30 >> $ps << EOF
101.5 -0.5 Sumatra
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,Helvetica,black+jLB -Gwhite@30 >> $ps << EOF
121 9 PHILIPPINES
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,Helvetica,black+jLB -Gwhite@20 >> $ps << EOF
98 7.5 THAILAND
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Helvetica-Oblique,yellow+jLB >> $ps << EOF
94 -9.5 I N D I A N
94 -11.0 O C E A N
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Helvetica,blue+jLB -Gwhite@30 >> $ps << EOF
106 7.0 South China
108 6.0 Sea
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,Helvetica,blue+jLB -Gwhite@30 >> $ps << EOF
120.5 4 Celebes Sea
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Helvetica,blue+jLB -Gwhite@30 >> $ps << EOF
108 -4.8 Java Sea
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,Helvetica,blue+jLB -Gwhite@30 >> $ps << EOF
124 -4.8 Banda
124.5 -5.8 Sea
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Helvetica,blue+jLB -Gwhite@30 >> $ps << EOF
126.0 -11 Timor
126.4 -12 Sea
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f7p,Helvetica,blue+jLB -Gwhite@30 >> $ps << EOF
127 8 Philippine
127.8 7.1 Sea
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f7p,Helvetica,red+jLB -Gwhite@30 >> $ps << EOF
90.5 0.2 Equator
EOF

# Add GMT logo
gmt logo -Dx6.2/-2.0+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y5.7c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
3.0 9.9 GEBCO 15 arc sec resolution global terrain model grid
EOF

# Convert to image file using GhostScript
gmt psconvert Bathymetry_ST.ps -A0.5c -E720 -Tj -Z
