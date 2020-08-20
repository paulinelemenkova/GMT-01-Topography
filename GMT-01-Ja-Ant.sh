#!/bin/sh
# Purpose: shaded relief grid raster map from the ETOPO1/GEBCO datasets (here: Ross Sea)
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert

# Step-2. GMT set up
gmt set FORMAT_GEO_MAP=dddF \
    MAP_FRAME_PEN=dimgray \
    MAP_FRAME_WIDTH=0.1c \
    MAP_TITLE_OFFSET=0.8c \
    MAP_ANNOT_OFFSET=0.1c \
    MAP_TICK_PEN_PRIMARY=thinner,dimgray \
    MAP_GRID_PEN_PRIMARY=thin,white \
    MAP_GRID_PEN_SECONDARY=thinnest,white \
    FONT_TITLE=12p,Palatino-Roman,black \
    FONT_ANNOT_PRIMARY=7p,Helvetica,dimgray \
    FONT_LABEL=7p,Helvetica,dimgray
# Step-3. Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults

#grdcut ETOPO1_Ice_g_gmt4.grd -R-180/180/-90/-60 -Ga_relief.nc
grdcut GEBCO_2019.nc -R-180/180/-90/-60 -Ga_relief.nc

gdalinfo a_relief.nc -stats
# Minimum=-6764.000, Maximum=3751.000

# Make color palette
gmt makecpt -Cgeo.cpt -V -T-7160/4763 > myocean.cpt

gmt set FONT_ANNOT_PRIMARY 12p FONT_LABEL 12p PROJ_ELLIPSOID WGS-84 FORMAT_GEO_MAP dddF

# Generate a file
ps=Antarctica.ps
#gmt pscoast -R-180/180/-90/-60 -Js0/-90/-71/1:60000000 -Bafg -Di -W0.25p -K > $ps
gmt pscoast -R-180/180/-90/-60 -Js0/-90/-71/1:60000000 -Di -W0.25p -K > $ps
gmt grdimage -Cmyocean.cpt a_relief.nc -R -J -Q -P -O -K >> $ps

# Add grid
gmt psbasemap -R -J \
    -Bpx104f5a30 -Bpyg10f5a5 -Bsxg5 -Bsyg5 \
    --MAP_TITLE_OFFSET=1.0c \
    --MAP_ANNOT_OFFSET=0.1c \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,black \
    --FONT_LABEL=7p,Helvetica,black \
    -B+t"Topographic map of the Antarctic" \
    -Lx9.2c/-3.1c+c318/-57+w2000k+l"Stereographic Equal-Angle projection"+f \
    -UBL/0.3c/-85p -O -K >> $ps

# Add shorelines
gmt grdcontour a_relief.nc -R -J -C2000 -W0.1p -O -K >> $ps

# Texts
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,Helvetica,red+jLB >> $ps << EOF
195.5 -75.0 R O S S
193.0 -71.5 S E A
EOF

gmt psscale -R -J -Cmyocean.cpt\
    -DjBC+o0.0c/-7.5c+w10.5c/0.5c+h\
    --FONT_LABEL=7p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,dimgray \
    --MAP_LABEL_OFFSET=0.1c \
    -Bg1000f200a2000+l"Color scale: geo [R=-7160/4763, H=0, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps

# Add GMT logo
gmt logo -Dx4.7/-3.5+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y4.7c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
1.0 11.0 GEBCO global terrain model, 15 arc sec resolution grid
0.6 10.3 Polar stereographic conformal projection, scale 1:60,000,000
EOF

# Convert to image file using GhostScript
gmt psconvert Antarctica.ps -A1.0c -E720 -Tj -Z
