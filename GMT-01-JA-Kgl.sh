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

# grdcut ETOPO1_Ice_g_gmt4.grd -R20/101/-70/-35 -Gkgl_relief.nc
# grdcut ETOPO1_Ice_g_gmt4.grd -R20/130/-75/-35 -Gkgl_relief.nc
#grdcut GEBCO_2019.nc -R20/130/-75/-35 -Gkgl_relief.nc

gdalinfo ss_relief.nc -stats
# Minimum=-8239.000, Maximum=6392.000
# Make color palette
gmt makecpt -Cgeo.cpt -V -T-8239/6392 > myocean.cpt
#makecpt --help

# Generate a file
ps=Bathymetry_Kgl.ps
gmt grdimage kgl_relief.nc -Cmyocean.cpt -R20/-70/101/-35r -JA60/-50/5.5i -P -I+a15+ne0.75 -Xc -K > $ps

# Add shorelines
gmt grdcontour kgl_relief.nc -R -J -C2000 -W0.1p -O -K >> $ps

# Add grid
gmt psbasemap -R -J \
    -Bpxg10f5a5 -Bpyg10f5a5 -Bsxg5 -Bsyg5 \
    --MAP_TITLE_OFFSET=1.5c \
    --MAP_ANNOT_OFFSET=0.1c \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,dimgray \
    --FONT_LABEL=6p,Helvetica,dimgray \
    -B+t"Topographic map of the Kerguelen Plateau" \
    -Lx12.0c/-1.3c+c318/-57+w1000k+l"Scale (km) at 60\232E 50\232S"+f \
    -UBL/-5p/-40p -O -K >> $ps

# Texts
gmt pstext -R -J -X0.0c -Y0.0c -N -O -K \
    -F+jTL+f8p,Times-Roman,red+jLB+a-65 -Gwhite@30 >> $ps << EOF
71.4 -50.0 Kergelen
EOF
gmt pstext -R -J -X0.0c -Y0.0c -N -O -K \
    -F+jTL+f8p,Times-Roman,red+jLB+a-65 -Gwhite@30 >> $ps << EOF
76.5 -55.0 Plateau
EOF
gmt pstext -R -J -X0.0c -Y0.0c -N -O -K \
    -F+jTL+f7p,Times-Roman,black+jLB -Gwhite@30 >> $ps << EOF
71.0 -49.0 Kergelen Island
EOF
gmt pstext -R -J -X0.0c -Y0.0c -N -O -K \
    -F+jTL+f7p,Times-Roman,black+jLB -Gwhite@30 >> $ps << EOF
74.0 -53.5 Heard & McDonald
74.0 -54.3 Island
EOF
gmt pstext -R -J -X0.0c -Y0.0c -N -O -K \
    -F+jTL+f6p,Times-Roman,black+jLB -Gwhite@30 >> $ps << EOF
74.0 -59.0 Banzare
76.0 -59.5 Bank
EOF
gmt pstext -R -J -X0.0c -Y0.0c -N -O -K \
    -F+jTL+f6p,Times-Roman,black+jLB -Gwhite@30 >> $ps << EOF
65.0 -56.0 Elan
65.0 -57.0 Bank
EOF
gmt pstext -R -J -X0.0c -Y0.0c -N -O -K \
    -F+jTL+f6p,Times-Roman,black+jLB -Gwhite@40 >> $ps << EOF
62.0 -50.0 Leclaire
62.0 -51.0 Rise
EOF
gmt pstext -R -J -X0.0c -Y0.0c -N -O -K \
    -F+jTL+f9p,Helvetica,white+jLB >> $ps << EOF
57.0 -45.1 Crozet Basin
EOF
gmt pstext -R -J -X0.0c -Y0.0c -N -O -K \
    -F+jTL+f9p,Helvetica,white+jLB >> $ps << EOF
81.0 -49.0 Australia-Antarctica
82.0 -50.5 Basin
EOF
gmt pstext -R -J -X0.0c -Y0.0c -N -O -K \
    -F+jTL+f9p,Helvetica,white+jLB >> $ps << EOF
66.0 -62.0 Enderby
66.5 -63.0 Basin
EOF
gmt pstext -R -J -X0.0c -Y0.0c -N -O -K \
    -F+jTL+f9p,Helvetica,white+jLB >> $ps << EOF
82.0 -57.0 Labuan
82.5 -58.0 Basin
EOF
gmt pstext -R -J -X0.0c -Y0.0c -N -O -K \
    -F+jTL+f8p,Times-Roman,white+jLB >> $ps << EOF
50.5 -72.0 A  N  T  A  R  C  T  I  C  A
EOF

# Add legend
gmt psscale -Dg14.0/-67+w9.5c/0.4c+v+o-7.0c/-5.3c+ml -R270/340/-65/-45 -J -Cmyocean.cpt \
    --FONT_LABEL=7p,Helvetica,dimgray \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,black \
    -Bg1000f200a2000+l"Color scale: geo global bathymetry/topography relief [R=-8239/6392, H=0, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps

# Add GMT logo
gmt logo -Dx5.8/-2.2+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y6.7c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
1.8 6.1 ETOPO1 global terrain model, 1 arc min resolution grid
#-0.5 7.4 GEBCO global terrain model, 15 arc sec resolution grid (GEBCO Compilation Group, 2020)
-0.5 5.5 Lambert Azimuthal Equal-Area projection. Central meridian 60\232E, standard parallel 50\232S
EOF

# Convert to image file using GhostScript
gmt psconvert Bathymetry_Kgl.ps -A0.5c -E720 -Tj -Z
