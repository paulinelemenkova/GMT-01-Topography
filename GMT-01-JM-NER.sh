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

#grdcut GEBCO_2019.nc -R65/107/-35/21 -Gner_relief.nc
#grdcut ETOPO1_Ice_g_gmt4.grd -R65/107/-35/21 -Gner_relief.nc

gdalinfo ner_relief.nc -stats
# Minimum=-6857.000, Maximum=3206.000
# Make color palette
# makecpt --help
#gmt makecpt -Cdem3.cpt -V -T-6857/3206 > myocean.cpt
#gmt makecpt -Cdem2.cpt -V -T-6857/3206 > myocean.cpt
#gmt makecpt -Cgeo.cpt -V -T-6857/3206 > myocean.cpt
gmt makecpt -Crelief.cpt -V -T-6857/3206 > myocean.cpt

# Generate a file
ps=Bathymetry_NER.ps
# Make raster image
gmt grdimage ner_relief.nc -Cmyocean.cpt -R65/107/-35/21 -JM6i -P -I+a15+ne0.75 -Xc -K > $ps

# Add grid
gmt psbasemap -R -J \
    -Bpx10f5a5 -Bpyg10f5a5 -Bsxg5 -Bsyg5 \
    --MAP_TITLE_OFFSET=0.8c \
    --FONT_TITLE=14p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=7p,Helvetica,black \
    -B+t"Bathymetric map of the Ninety East Ridge region, Indian Ocean" -O -K >> $ps
    
# Add shorelines
gmt grdcontour ner_relief.nc -R -J -C1000 -W0.1p -O -K >> $ps
    
# Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=8p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=8p,Helvetica,black \
    --MAP_LABEL_OFFSET=0.1c \
    -Lx12.7c/-2.5c+c50+w1000k+l"Mercator projection. Scale: km"+f \
    -UBL/-5p/-75p -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P \
    -Ia/thinnest,blue -Na -N1/thinner,red -W0.1p -Df -O -K >> $ps

# Texts
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,Helvetica,black+jLB+a-53 -Gwhite@40>> $ps << EOF
69.5 -26.4 South-East Indian Ridge
EOF

gmt pstext -R -J -N -O -K \
-F+jTL+f11p,Helvetica,black+jLB+a-73 -Gwhite@40>> $ps << EOF
67.5 2.0 C e n t r a l
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,Helvetica,black+jLB+a-285 -Gwhite@40>> $ps << EOF
68.5 -10.5 I n d i a n
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,Helvetica,black+jLB+a-53 -Gwhite@40>> $ps << EOF
67.0 -17.5 R i d g e
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Helvetica,white+jLB+a-49 >> $ps << EOF
101.0 0.5 S u m a t r a
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,Helvetica,white+jLB+a-274 >> $ps << EOF
89.6 -27.0 N     i     n     e     t     y        E     a     s     t        R     i     d     g     e
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,Helvetica,black+jLB+a-285 -Gwhite@40 >> $ps << EOF
71.0 -9.5 Chagos
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,Helvetica,white+jLB+a-265 >> $ps << EOF
72.0 -2.0 L a c c a d i v e   R i d g e
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,Helvetica,black+jLB+a-267 -Gwhite@40 >> $ps << EOF
73.5 1.0 M a l d i v e s
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,Helvetica,white+jLB >> $ps << EOF
92.0 -12.0 Warton Basin
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,Helvetica,red+jLB -Gwhite@40 >> $ps << EOF
102.5 0.2 Equator
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,Helvetica,white+jLB >> $ps << EOF
75.3 -4.5 Central
75.3 -6.5 Indian
75.3 -8.5 Basin
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,Helvetica,white+jLB >> $ps << EOF
82.0 -14.0 Osborn
82.0 -15.0 Plateau
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f13p,Helvetica,blue+jLB >> $ps << EOF
86.0 17.5 Bay of
86.0 15.5 Bengal
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f13p,Helvetica,white+jLB >> $ps << EOF
65.5 17.5 Arabian
65.5 15.5 Sea
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,Helvetica,black+jLB -Gwhite@40 >> $ps << EOF
74.0 17.0 I  n  d  i  a
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f13p,Helvetica,black+jLB -Gwhite@40 >> $ps << EOF
99.0 16.0 Thailand
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,Helvetica,white+jLB+a-54 >> $ps << EOF
101.0 5.6 Malaysia
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,Helvetica,black+jLB -Gwhite@40 >> $ps << EOF
82.2 9.5 Sri
82.2 8.5 Lanka
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,Helvetica,yellow+jLB+a-274 >> $ps << EOF
86.0 -4.0 85\232E Ridge
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,Helvetica,white+jLB+a-53 >> $ps << EOF
95.5 0.5 Sunda Trench
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,Helvetica,black+jLB+a-10 >> $ps << EOF
92.0 -30.5 Broken Ridge
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,Helvetica,blue+jLB -Gwhite@40 >> $ps << EOF
70.5 -23.5 Rodrigues
70.5 -24.5 Triple
70.5 -25.5 Junction
EOF
#

# Add legend
gmt psscale -Dg65/-38+w15.2c/0.4c+h+o0.0/0i+ml -R -J -Cmyocean.cpt \
    --FONT_LABEL=6p,Helvetica,black \
    --MAP_LABEL_OFFSET=0.1c \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,black \
    -Baf+l"Color scale 'relief': Wessel/Martinez colors for topography [R=-6857/3206, H=0, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps

# Add GMT logo
gmt logo -Dx6.2/-3.3+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y13.0c -N -O \
    -F+f12p,Helvetica,black+jLB >> $ps << EOF
2.5 13.5 GEBCO 15 arc sec resolution global terrain model grid
EOF

# Convert to image file using GhostScript
gmt psconvert Bathymetry_NER.ps -A1.0c -E720 -Tj -Z
