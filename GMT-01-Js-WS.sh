#!/bin/sh
# Purpose: shaded relief grid raster map from the ETOPO1/GEBCO datasets (here: Weddell Sea)
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

#grdcut ETOPO1_Ice_g_gmt4.grd -R270/360/-80/-40 -Gws_relief.nc
grdcut ETOPO1_Ice_g_gmt4.grd -R290/360/-80/-40 -Gws_relief.nc
#grdcut GEBCO_2019.nc -R290/371/-80/-60 -Gws_relief.nc

gdalinfo ws_relief.nc -stats
# Minimum=-7160.000, Maximum=4763.000
# Step-5. Make color palette
gmt makecpt -Cgeo.cpt -V -T-7160/4763 > myocean.cpt
#makecpt --help

# Generate a file
ps=Bathymetry_WS.ps
#gmt grdimage ws_relief.nc -Cmyocean.cpt -R270/-80/371/-60r -JA315/-70/5.5i -P -I+a15+ne0.75 -Xc -K > $ps
#gmt grdimage ws_relief.nc -Cmyocean.cpt -R270/360/-80/-60 -JM5.5i -P -I+a15+ne0.75 -Xc -K > $ps
#polar stereo
gmt grdimage ws_relief.nc -Cmyocean.cpt -R290/360/-80/-60 -Js325/-90/4.5i/-60 -I+a15+ne0.75 -Xc -K > $ps
# Rectangular stereographic map
#gmt grdimage ws_relief.nc -Cmyocean.cpt -R270/-80/371/-50r -JS315/-90/5.5i -P -I+a15+ne0.75 -Xc -K > $ps

# Add grid
gmt psbasemap -R -J \
    -Bpx104f5a10 -Bpyg10f5a5 -Bsxg5 -Bsyg5 \
    --MAP_TITLE_OFFSET=1.4c \
    --MAP_ANNOT_OFFSET=0.1c \
    -B+t"Topographic map of the Weddell Sea region" \
    -Lx9.6c/-3.0c+c318/-57+w1000k+l"Polar stereographic projection"+f \
    -UBL/1.5c/-85p -O -K >> $ps

# Add shorelines
gmt grdcontour ss_relief.nc -R -J -C2000 -W0.1p -O -K >> $ps

# Texts
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,Helvetica,white+jLB >> $ps << EOF
318 -67.0 W E D D E L L
322 -68.5 S E A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,Times−Bold,black+jLB -Gwhite@40 >> $ps << EOF
291 -67.0 Antarctic
290 -67.8 Peninsula
EOF

gmt psscale -R -J -Cmyocean.cpt\
    -DjBC+o0.0c/-3.0c+w10c/0.5c+h\
    --FONT_LABEL=7p,Helvetica,dimgray \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,dimgray \
    --MAP_LABEL_OFFSET=0.1c \
    -Baf+l"Color scale: geo [R=-7160/4763, H=0, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps

# Add GMT logo
gmt logo -Dx5.2/-1.2+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y4.7c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
#2.1 7.4 ETOPO1 global terrain model, 1 arc min resolution grid
2.1 7.4 GEBCO global terrain model, 15 arc sec resolution grid
-0.5 6.8 Polar stereographic conformal projection. Central meridian 35\232W, standard parallel 60\232S
EOF

# Convert to image file using GhostScript
gmt psconvert Bathymetry_WS.ps -A1.0c -E720 -Tj -Z
