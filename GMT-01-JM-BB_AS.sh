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
    --FONT_TITLE=13p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=7p,Helvetica,black \
    -B+t"Bathymetric map of the Bay of Bengal and Andaman Sea region, Indian Ocean" -O -K >> $ps
    
# Add shorelines
gmt grdcontour bb_relief.nc -R -J -C1000 -W0.1p -O -K >> $ps
    
# Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=8p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=9p,Helvetica,black \
    --MAP_LABEL_OFFSET=0.1c \
    -Lx12.7c/-2.5c+c50+w800k+l"American polyconic projection. Scale: km"+f \
    -UBL/-5p/-75p -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P \
    -Ia/thinnest,blue -Na -N1/thinner,red -W0.1p -Df -O -K >> $ps

# Add color scale
gmt psscale -Dg74/-0.5+w15.2c/0.4c+h+o0.0/0i+ml -R -J -Cmyocean.cpt \
    --FONT_LABEL=6p,Helvetica,black \
    --MAP_LABEL_OFFSET=0.1c \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,black \
    -Baf+l"Color scale 'geo': Colors for global bathymetry/topography relief [R=-5339/3206, H=0, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps

# Texts
gmt pstext -R -J -N -O -K \
-F+jTL+f13p,Helvetica,blue+jLB >> $ps << EOF
87.0 16.5 Bay of
87.0 14.5 Bengal
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,Helvetica,white+jLB >> $ps << EOF
75.0 17.0 I  n  d  i  a
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f13p,Helvetica,black+jLB+a-80 -Gwhite@40 >> $ps << EOF
99.0 19.0 Thailand
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,Helvetica,white+jLB+a-54 >> $ps << EOF
101.0 5.6 Malaysia
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,Helvetica,black+jLB -Gwhite@40 >> $ps << EOF
81.2 9.5 Sri
81.4 8.7 Lanka
EOF
#

# Add GMT logo
gmt logo -Dx6.2/-3.3+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y2.0c -N -O \
    -F+f12p,Helvetica,black+jLB >> $ps << EOF
2.5 16.6 GEBCO 15 arc sec resolution global terrain model grid
EOF

# Convert to image file using GhostScript
gmt psconvert Bathymetry_BB.ps -A0.8c -E720 -Tj -Z
