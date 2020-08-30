#!/bin/sh
# Purpose: shaded relief grid raster map from the ETOPO1/GEBCO datasets (here: Ross Sea)
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert

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
    FONT_LABEL=7p,Helvetica,dimgray
# Step-3. Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults

#grdcut ETOPO1_Ice_g_gmt4.grd -R160/220/-81/-40 -Grs_relief.nc
grdcut GEBCO_2019.nc -R160/220/-81/-40 -Grs_relief.nc

gdalinfo rs_relief.nc -stats
# Minimum=-6764.000, Maximum=3751.000
# Step-5. Make color palette
gmt makecpt -Cgeo.cpt -V -T-6764/3751 > myocean.cpt
#makecpt --help

# Generate a file
ps=Bathymetry_RS.ps
#gmt grdimage rs_relief.nc -Cmyocean.cpt -R270/-80/371/-60r -JA315/-70/5.5i -P -I+a15+ne0.75 -Xc -K > $ps
#gmt grdimage rs_relief.nc -Cmyocean.cpt -R270/360/-80/-60 -JM5.5i -P -I+a15+ne0.75 -Xc -K > $ps
#polar stereo
gmt grdimage rs_relief.nc -Cmyocean.cpt -R160/220/-81/-60 -Js190/-90/5.5i/-60 -I+a15+ne0.75 -Xc -K > $ps
# Rectangular stereographic map
#gmt grdimage rs_relief.nc -Cmyocean.cpt -R270/-80/371/-50r -JS315/-90/5.5i -P -I+a15+ne0.75 -Xc -K > $ps

# Add grid
gmt psbasemap -R -J \
    -Bpx104f5a10 -Bpyg10f5a5 -Bsxg5 -Bsyg5 \
    --MAP_TITLE_OFFSET=1.2c \
    --MAP_ANNOT_OFFSET=0.1c \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,black \
    --FONT_LABEL=7p,Helvetica,black \
    -B+t"Bathymetric map of the Ross Sea region" \
    -Lx9.7c/-3.1c+c318/-57+w1000k+l"Polar stereographic projection"+f \
    -UBL/2.8c/-85p -O -K >> $ps

# Add shorelines
gmt grdcontour rs_relief.nc -R -J -C2000 -W0.1p -O -K >> $ps

# Texts
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,Helvetica,white+jLB >> $ps << EOF
185.5 -67.0 R O S S
186.5 -68.5 S E A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,Helvetica,black+jLB >> $ps << EOF
175.5 -75.0 Ross
176.5 -76.2 Ice
177.5 -77.4 Shelf
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,Helvetica,black+jLB >> $ps << EOF
170.0 -71.0 Cape Adare
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,Helvetica,black+jLB -Gwhite@40 >> $ps << EOF
160.5 -71.8 Oates
160.5 -72.5 Land
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Helvetica,black+jLB+a-60 -Gwhite@40 >> $ps << EOF
160.1 -74.0 Victoria Land
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Helvetica,black+jLB >> $ps << EOF
200.0 -79.5 Marie Bird
210.0 -80.0 Land
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f7p,Helvetica,black+jLB+a-60 >> $ps << EOF
196.0 -75.0 Edward VII
195.0 -75.5 Peninsula
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,Helvetica,black+jLB -Gwhite@40 >> $ps << EOF
208.1 -77.0 Sulzberger
208.4 -77.5 Bay
EOF

gmt psscale -R -J -Cmyocean.cpt\
    -DjBC+o0.0c/-3.0c+w9c/0.5c+h\
    --FONT_LABEL=7p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,dimgray \
    --MAP_LABEL_OFFSET=0.1c \
    -Bg1000f500a2000+l"Color scale: geo [R=-7160/4763, H=0, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps

# Add GMT logo
gmt logo -Dx5.7/-1.3+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y4.7c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
#2.1 7.4 ETOPO1 global terrain model, 1 arc min resolution grid
2.2 10.3 GEBCO global terrain model, 15 arc sec resolution grid
0.0 9.6 Polar stereographic conformal projection. Central meridian 170\232W, standard parallel 60\232S
EOF

# Convert to image file using GhostScript
gmt psconvert Bathymetry_RS.ps -A2.0c -E720 -Tj -Z
