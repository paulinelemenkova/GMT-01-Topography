#!/bin/sh
# Purpose: shaded relief grid raster map from the ETOPO1 from 1 arc minute global data set (here: Ryukyu Trench)
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
# Step-5. Make color palette
gmt makecpt -Cgeo.cpt -V -T-7898/8271 > myocean.cpt
# makecpt --help
# Step-6. Make raster image
# gmt grdimage GEBCO_2019.nc -Cmyocean.cpt -R120/134/-80/-40 -JM6i -P -I+a15+ne0.75 -Xc -K > $ps
grdcut ETOPO1_Ice_g_gmt4.grd -R20/120/-65/30 -Gio2_relief.nc


# Step-1. Generate a file
ps=Bathymetry_IO.ps
gmt grdimage io2_relief.nc -Cmyocean.cpt -R20/120/-65/30 -JQ5.0i -P -I+a15+ne0.75 -Xc -K > $ps
# gmt grdimage GEBCO_2019_SID.nc -Cmyocean.cpt -R140/170/40/60 -JM6i -P -I+a15+ne0.75 -Xc -K > $ps

# Add shorelines
gmt grdcontour ETOPO1_Ice_g_gmt4.grd -R -J -C2000 -W0.1p -O -K >> $ps

# Add grid
gmt psbasemap -R -J \
    -Bpx204f10a10 -Bpyg20f10a10 -Bsxg5 -Bsyg5 \
    --MAP_TITLE_OFFSET=0.8c \
    -B+t"Bathymetry of the Indian Ocean and coastal land topography" -O -K >> $ps
    
# Step-10. Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=7p,Palatino-Roman,black \
    --MAP_TITLE_OFFSET=0.3c \
    -Tdx0.8c/10.3c+w0.3i+f2+l+o0.15i \
    -Lx11c/-1.3c+c50+w2000k+l"Cylindrical equidistant prj. Scale: km"+f \
    -UBL/-10p/-40p -O -K >> $ps

# Step-7. Add legend
gmt psscale -Dg0.0/-65+w12.0c/0.4c+v+o0.3/0i+ml -R20/120/-65/30 -J -Cmyocean.cpt \
    --FONT_LABEL=7p,Helvetica,dimgray \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,black \
    -Baf+l"Color scale: geo global bathymetry/topography relief [R=-8000/8000, H=0, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps
    
    
# Texts
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Times−Bold,yellow+jLB+a-325 >> $ps << EOF
27.0 -55.0 S o u t h w e s t   I n d i a n   R i d g e
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Times−Bold,yellow+jLB+a-20 >> $ps << EOF
78.0 -40.0 S o u t h e a s t  I n d i a n  R i d g e
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Times−Bold,yellow+jLB+a-52 >> $ps << EOF
66.0 -19.0 Mid-Indian Ridge
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Times−Bold,yellow+jLB+a-275 >> $ps << EOF
88.5 -30.0 N i n e t y  E a s t  R i d g e
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Times−Bold,yellow+jLB+a-40 >> $ps << EOF
57.2 10.0 Carlsberg
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Times−Bold,yellow+jLB+a-88 >> $ps << EOF
67.0 -0.2 R i d g e
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Times-Roman,black+jLB -Gwhite@30 >> $ps << EOF
22.0 5.0 A F R I C A
95.0 22.0 A S I A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,Times-Roman,yellow+jLB+a-3 >> $ps << EOF
90.5 -31.0 Broken Ridge
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Times-Roman,white+jLB >> $ps << EOF
61.0 18.0 Arabian
63.0 15.0 Sea
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Times-Roman,white+jLB >> $ps << EOF
84.0 15.0 Bay of
84.0 12.0 Bengal
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,Times-Roman,brown+jLB+a-30 -Gwhite@40 >> $ps << EOF
68.0 -51.5 Kerguelen Plateau
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,Times-Roman,yellow+jLB >> $ps << EOF
40.0 -56.0 Conrad Rise
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,Times-Roman,yellow+jLB >> $ps << EOF
45.0 -45.0 Del Cano
47.0 -48.0 Rise
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,Times-Roman,brown+jLB -Gwhite@40 >> $ps << EOF
25.0 -40.0 Agulhas
25.0 -42.5 Plateau
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,Times-Roman,brown+jLB+a-285 -Gwhite@40 >> $ps << EOF
35.0 -35.0 Mozambique
37.0 -35.0 Plateau
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,Times-Roman,brown+jLB -Gwhite@40 >> $ps << EOF
45.5 -30.0 Madagascar
45.5 -32.5 Plateau
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,Times-Roman,brown+jLB+a-47 -Gwhite@40 >> $ps << EOF
58.0 -5.0 Mascarene
55.0 -7.0 Plateau
EOF

# Step-11. Add GMT logo
gmt logo -Dx5.2/-2.2+o0.1i/0.1i+w2c -O -K >> $ps

# Step-12. Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y6.7c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
0.7 9.3 ETOPO1 global terrain model, 1 arc minute resolution grid
EOF

# Step-13. Convert to image file using GhostScript
gmt psconvert Bathymetry_IO.ps -A0.5c -E720 -Tj -Z
