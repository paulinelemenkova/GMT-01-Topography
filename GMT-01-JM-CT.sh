#!/bin/sh
# Purpose: shaded relief grid raster map from the ETOPO1 from 1 arc minute global data set (here: Cascadia Trench)
# GMT modules: gmtset, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert

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

# Extract a subset of ETOPO1m for the Kuril-Kamchatka Trench area
#grdcut ETOPO1_Ice_g_gmt4.grd -R224/240/35/55 -Gct_relief.nc
grdcut GEBCO_2019.nc -R224/240/35/55 -Gct_relief.nc
gdalinfo ct_relief.nc -stats
# Minimum=-6201.000, Maximum=4161.000

# Make color palette
gmt makecpt -Cgeo.cpt -V -T-6201/4161 > myocean.cpt

# Generate a file
ps=BathymetryCT.ps
# Make raster image
gmt grdimage ct_relief.nc -Cmyocean.cpt -R224/240/35/55 -JM6i -P -I+a15+ne0.75 -Xc -K > $ps

# Add grid
gmt psbasemap -R -J \
    -Bpxg8f2a4 -Bpyg6f3a3 -Bsxg4 -Bsyg3 \
    --MAP_TITLE_OFFSET=1.0c \
    -B+t"Bathymetry of the Cascadia Trench and coastal land topography" -O -K >> $ps
    
#gmt psxy -R -J trench.gmt -Sf1.5c/0.2c+l+t -Wthick,yellow -Gyellow -O -K >> $ps
    
# Add legend
gmt psscale -Dg217/35+w15.0c/0.4c+h+o7.0/-1.5c+ml -Rct_relief.nc -J -Cmyocean.cpt \
    --FONT_LABEL=8p,Helvetica,dimgray \
    --FONT_ANNOT_PRIMARY=5p,Helvetica,dimgray \
    -Baf+l"Color scale: geo global bathymetry/topography relief [R=-6201/4161, H=0, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps
    
# Add shorelines
gmt grdcontour ct_relief.nc -R -J -C1000 -W0.1p -O -K >> $ps

# Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=8p,Palatino-Roman,dimgray \
    --MAP_TITLE_OFFSET=0.3c \
    -Tdx1.0c/1.3c+w0.3i+f2+l+o0.15i \
    -Lx13.4c/-2.7c+c50+w300k+l"Mercator projection. Scale (km)"+f \
    -UBL/0p/-75p -O -K >> $ps
    
# Add GMT logo
gmt logo -Dx6.4/-3.5+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/14 -X0.5c -Y7.1c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
3.0 22.3 GEBCO global terrain model 15 arc-sec resolution grid
EOF

# Convert to image file using GhostScript
gmt psconvert BathymetryCT.ps -A2.5c -E720 -Tj -Z
