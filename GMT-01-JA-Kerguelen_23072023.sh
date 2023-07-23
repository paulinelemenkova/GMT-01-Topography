#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO global data set (here: Kergelen)
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

# grdcut ETOPO1_Ice_g_gmt4.grd -R20/130/-75/-35 -Gkgl_relief.nc
#grdcut GEBCO_2019.nc -R20/130/-75/-35 -Gkgl_relief.nc

gmt grdcut ETOPO1_Ice_g_gmt4.grd -R-40/150/-70/-10 -Gkgl_relief.nc

gdalinfo ss_relief.nc -stats
# Minimum=-8239.000, Maximum=6392.000
# Make color palette
gmt makecpt -Cgeo.cpt -V -T-8239/6392 -N > myocean.cpt
# gmt makecpt --help

# Generate a file
ps=Bathymetry_Kgl.ps
#gmt grdimage kgl_relief.nc -Cmyocean.cpt -R0/-70/101/-30r -JA60/-50/5.5i -P -I+a15+ne0.75 -Xc -K > $ps
#gmt grdimage kgl_relief.nc -Cmyocean.cpt -R-50/-65/101/-20r -JA60/-50/7.5i -P -I+a15+ne0.75 -Xc -K > $ps
gmt grdimage kgl_relief.nc -Cmyocean.cpt -R-25/-65/101/-10r -JA55/-50/7.5i -P -I+a15+ne0.75 -Xc -K > $ps

# Add shorelines
gmt grdcontour kgl_relief.nc -R -J -C3000 -Wthinnest,blue -O -K >> $ps

# Add grid
gmt psbasemap -R -J \
    -Bpxg10f5a10 -Bpyg10f5a15 -Bsxg5 -Bsyg5 \
    --MAP_TITLE_OFFSET=1.5c \
    --MAP_ANNOT_OFFSET=0.1c \
    --MAP_FRAME_AXES=wESN \
    --FONT_ANNOT_PRIMARY=10p,0,dimgray \
    --FONT_LABEL=10p,0,dimgray \
    --FONT_TITLE=13p,0,black \
    -B+t"Topographic map of the Kerguelen Plateau" \
    -Lx15.5c/-1.6c+c318/-57+w2000k+l"Scale (km) at 60\232E 50\232S"+f \
    -UBL/-5p/-40p -O -K >> $ps

# Texts
gmt pstext -R -J -X0.0c -Y0.0c -N -O -K \
    -F+jTL+f14p,0,red+jLB+a-72 -Gwhite@70 >> $ps << EOF
70.1 -50.0 Kergelen
EOF
gmt pstext -R -J -X0.0c -Y0.0c -N -O -K \
    -F+jTL+f14p,0,red+jLB+a-70 -Gwhite@70 >> $ps << EOF
76.5 -57.0 Plateau
EOF
gmt pstext -R -J -X0.0c -Y0.0c -N -O -K \
    -F+jTL+f13p,0,black+jLB -Gwhite@60 >> $ps << EOF
71.0 -49.0 Kergelen Island
EOF
gmt pstext -R -J -X0.0c -Y0.0c -N -O -K \
    -F+jTL+f11p,0,white+jLB >> $ps << EOF
80.0 -53.5 Heard & McDonald
81.0 -55.0 Island
EOF
gmt pstext -R -J -X0.0c -Y0.0c -N -O -K \
    -F+jTL+f11p,0,white+jLB >> $ps << EOF
65.5 -59.0 Banzare
65.5 -60.6 Bank
EOF
gmt pstext -R -J -X0.0c -Y0.0c -N -O -K \
    -F+jTL+f11p,0,white+jLB >> $ps << EOF
65.0 -56.0 Elan
65.0 -57.5 Bank
EOF
gmt pstext -R -J -X0.0c -Y0.0c -N -O -K \
    -F+jTL+f11p,0,white+jLB >> $ps << EOF
59.0 -50.0 Leclaire
61.0 -52.0 Rise
EOF
gmt pstext -R -J -X0.0c -Y0.0c -N -O -K \
    -F+jTL+f11p,0,white+jLB >> $ps << EOF
57.0 -45.1 Crozet Basin
EOF
gmt pstext -R -J -X0.0c -Y0.0c -N -O -K \
    -F+jTL+f11p,0,white+jLB >> $ps << EOF
81.0 -49.0 Australia-Antarctica
82.0 -50.5 Basin
EOF
gmt pstext -R -J -X0.0c -Y0.0c -N -O -K \
    -F+jTL+f11p,0,white+jLB >> $ps << EOF
66.0 -63.5 Enderby
66.5 -65.0 Basin
EOF
gmt pstext -R -J -X0.0c -Y0.0c -N -O -K \
    -F+jTL+f11p,0,white+jLB >> $ps << EOF
87.0 -57.0 Labuan
88.0 -58.5 Basin
EOF
gmt pstext -R -J -X0.0c -Y0.0c -N -O -K \
    -F+jTL+f10p,0,white+jLB >> $ps << EOF
30.0 -76.0 A  N  T  A  R  C  T  I  C  A
EOF

# Add legend
gmt psscale -Dg-33/-59+w15.4c/0.4c+v+ml+e -R -J -Cmyocean.cpt \
    --FONT_LABEL=10p,0,black \
    --FONT_ANNOT_PRIMARY=10p,0,black \
    -Bg1000f200a2000+l"Color scale: 'geo' global bathymetry/topography relief [R=-8239/6392, H=0, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps

# Add GMT logo
gmt logo -Dx5.5/-2.2+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y13.0c -N -O \
    -F+f12p,0,black+jLB >> $ps << EOF
4.0 6.1 ETOPO1 global terrain model, 1 arc min resolution grid
#-0.5 7.4 GEBCO global terrain model, 15 arc sec resolution grid (GEBCO Compilation Group, 2020)
2.0 5.5 Lambert Azimuthal Equal-Area projection. Central meridian 55\232E, standard parallel 50\232S
EOF

# Convert to image file using GhostScript
gmt psconvert Bathymetry_Kgl.ps -A1.5c -E720 -Tj -Z
