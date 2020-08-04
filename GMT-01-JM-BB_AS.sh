#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO dataset (here: Ninety East Ridge, Indian Ocean)
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

grdcut GEBCO_2019.nc -R74/100/2/23 -Gbb_relief.nc
#grdcut ETOPO1_Ice_g_gmt4.grd -R74/100/2/23 -Gbb_relief.nc

gdalinfo bb_relief.nc -stats
# Minimum=-5339.000, Maximum=3206.000
# Make color palette
# makecpt --help
#gmt makecpt -Cdem3.cpt -V -T-6857/3206 > myocean.cpt
#gmt makecpt -Cdem2.cpt -V -T-6857/3206 > myocean.cpt
#gmt makecpt -relief.cpt -V -T-6857/3206 > myocean.cpt
gmt makecpt -Cgeo.cpt -V -T-5339/3206 > myocean.cpt

# Generate a file
ps=Bathymetry_BB.ps
# Make raster image
#gmt grdimage bb_relief.nc -Cmyocean.cpt -R74/100/2/23 -JM6i -P -I+a15+ne0.75 -Xc -K > $ps
#gmt grdimage bb_relief.nc -Cmyocean.cpt -R74/100/2/23 -JQ6.0i -P -I+a15+ne0.75 -Xc -K > $ps
gmt grdimage bb_relief.nc -Cmyocean.cpt -R74/100/2/23 -JPoly/6.0i -P -I+a15+ne0.75 -Xc -K > $ps

# Add grid
gmt psbasemap -R -J \
    -Bpx10f5a5 -Bpyg10f5a5 -Bsxg5 -Bsyg5 \
    --MAP_TITLE_OFFSET=0.8c \
    --FONT_TITLE=12p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=7p,Helvetica,black \
    -B+t"Topographic map of the Bay of Bengal and Andaman Sea region, Indian Ocean" -O -K >> $ps
    
# Add shorelines
gmt grdcontour bb_relief.nc -R -J -C1000 -W0.1p -O -K >> $ps
    
# Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=8p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=9p,Helvetica,black \
    --MAP_LABEL_OFFSET=0.1c \
    -Lx12.7c/-2.4c+c50+w800k+l"American polyconic projection. Scale: km"+f \
    -UBL/-5p/-70p -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P \
    -Ia/thinnest,blue -Na -N1/thinner,red -W0.1p -Df -O -K >> $ps

# Add color scale -Baf+l
gmt psscale -Dg74/-0.3+w15.2c/0.4c+h+o0.0/0i+ml -R -J -Cmyocean.cpt \
    --FONT_LABEL=7p,Helvetica,black \
    --MAP_LABEL_OFFSET=0.1c \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,black \
    -Bg500f100a1000+l"Color scale 'geo': Colors for global bathymetry/topography relief [R=-5339/3206, H=0, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps

# Texts
gmt pstext -R -J -N -O -K \
-F+jTL+f13p,Helvetica,white+jLB >> $ps << EOF
87.3 16.5 Bengal Fan
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f13p,Helvetica,white+jLB >> $ps << EOF
86.8 11.8 Bay of
86.0 10.8 B e n g a l
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,Helvetica,white+jLB >> $ps << EOF
75.5 17.4 I  N  D  I  A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,Helvetica,blue+jLB+a-265 >> $ps << EOF
95.8 18.5 Irrawaddy
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,Helvetica,blue+jLB+a-350 -Gwhite@35 >> $ps << EOF
88.2 21.0 Ganges Fan
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,Helvetica,black+jLB -Gwhite@30 >> $ps << EOF
97.7 18.0 Thailand
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,Helvetica,black+jLB -Gwhite@30 >> $ps << EOF
94.0 21.7 Myanmar
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,Helvetica,black+jLB+a-54 -Gwhite@30 >> $ps << EOF
98.3 9.5 Malaysia
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,Helvetica,black+jLB+a-48 -Gwhite@30 >> $ps << EOF
96.5 4.8 Indonesia
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,Helvetica,black+jLB -Gwhite@30 >> $ps << EOF
89.1 22.5 Bangladesh
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,Helvetica,white+jLB >> $ps << EOF
80.1 8.6 Sri
80.1 7.9 Lanka
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,Helvetica,blue+jLB -Gwhite@30 >> $ps << EOF
94.5 10.5 Andaman
95.3 9.2 Sea
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,Helvetica,black+jLB -Gwhite@35 >> $ps << EOF
93.3 13.0 Andaman
93.3 12.4 Islands
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,Helvetica,black+jLB -Gwhite@35 >> $ps << EOF
94.0 8.0 Nicobar
94.2 7.4 Islands
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,Helvetica,white+jLB+a-275 >> $ps << EOF
89.8 2.5 Ninety East Ridge
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,Helvetica,white+jLB >> $ps << EOF
81.0 3.0 Ceylon Plain
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Helvetica,blue+jLB+a-35 >> $ps << EOF
97.8 6.2 Strait of
97.8 5.5 Malacca
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,Helvetica,black+jLB+a-310 >> $ps << EOF
79.3 9.0 Palk Strait
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,Helvetica,white+jLB >> $ps << EOF
78.4 8.0 Gulf
78.6 7.4 of
77.8 6.8 Mannar
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,Helvetica,white+jLB+a-60 >> $ps << EOF
74.6 9.2 Laccadive
74.4 8.4 Sea
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,Helvetica,blue+jLB+a-345 >> $ps << EOF
78.0 16.3 Krishna
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,Helvetica,blue+jLB+a-53 >> $ps << EOF
79.8 18.4 Godavari
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,Helvetica,blue+jLB+a-5 >> $ps << EOF
78.0 10.5 Kaveri
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,Helvetica,blue+jLB >> $ps << EOF
84.0 20.1 Mahanadi
EOF
#

# Add GMT logo
gmt logo -Dx6.2/-3.2+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y2.0c -N -O \
    -F+f12p,Helvetica,black+jLB >> $ps << EOF
2.5 16.6 GEBCO 15 arc sec resolution global terrain model grid
EOF

# Convert to image file using GhostScript
gmt psconvert Bathymetry_BB.ps -A0.8c -E720 -Tj -Z
