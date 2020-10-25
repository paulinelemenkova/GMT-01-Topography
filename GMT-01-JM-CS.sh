#!/bin/sh
# Purpose: shaded relief grid raster map from the ETOPO1 from 1 arc minute global data set (here: Caribbean Sea)
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
# Step-3. Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults

grdcut GEBCO_2019.nc -R270/305/7/25 -Gcs_relief.nc
#grdcut ETOPO1_Ice_g_gmt4.grd -R270/305/7/24 -Gcs_relief.nc

gdalinfo cs_relief.nc -stats
# -8619.841796875,5535.625
# Make color palette
# makecpt --help
gmt makecpt -Cgeo.cpt -V -T-8620/5536 > myocean.cpt

# Generate a file
ps=Bathymetry_CS.ps
# Make raster image
gmt grdimage cs_relief.nc -Cmyocean.cpt -R270/305/7/24 -JM6i -P -I+a15+ne0.75 -Xc -K > $ps

# Add grid
gmt psbasemap -R -J \
    -Bpx104f2.5a5 -Bpyg10f2.5a5 -Bsxg5 -Bsyg5 \
    --FONT_ANNOT_PRIMARY=7p,Helvetica,dimgray \
    --FONT_LABEL=7p,Helvetica,dimgray \
    --MAP_TITLE_OFFSET=0.8c \
    --MAP_FRAME_AXES=wESN \
    -B+t"Topographic map of the Caribbean Sea region" -O -K >> $ps
    
# Add shorelines
gmt grdcontour cs_relief.nc -R -J -C1000 -W0.1p -O -K >> $ps
    
# Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=8p,Palatino-Roman,black \
    --MAP_TITLE_OFFSET=0.3c \
    -Tdx13.8c/1.0c+w0.2i+f2+l+o0.1c \
    -Lx12.7c/-1.3c+c50+w700k+l"Mercator projection. Scale: km"+f \
    -UBL/-5p/-40p -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P \
    -Ia/thinnest,blue -Na -N1/thinner,red -W0.1p -Df -O -K >> $ps

# Add legend
gmt psscale -Dg265.5/7+w7.7c/0.4c+v+o0.3/0i+ml -R270/305/7/24 -J -Cmyocean.cpt \
    --FONT_LABEL=6p,Helvetica,dimgray \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,black \
    -Ba2000f200+l"Color scale: geo global bathymetry/topography relief [R=-8620/5536, H=0, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps

# Texts
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,Helvetica,black+jLB+a-65 -Gwhite@40 >> $ps << EOF
298.0 18.0 L e s s e r
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,Helvetica,black+jLB+a-86 -Gwhite@40 >> $ps << EOF
299.3 15.1 Antilles
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Helvetica,yellow+jLB >> $ps << EOF
282.4 15.6 C A R I B B E A N  S E A
293 22.0 A T L A N T I C   O C E A N
270.2 9.0 PACIFIC
270.2 8.2 OCEAN
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,Helvetica,black+jLB+a-30 -Gwhite@40 >> $ps << EOF
281 22 Cuba
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f7p,Helvetica,black+jLB -Gwhite@40 >> $ps << EOF
282 18.7 Jamaica
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f7p,Helvetica,black+jLB -Gwhite@40 >> $ps << EOF
287.5 17.5 Hispaniola
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f7p,Helvetica,black+jLB -Gwhite@40 >> $ps << EOF
293 17.5 Puerto Rico
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,Helvetica,black+jLB+a-20 -Gwhite@30 >> $ps << EOF
279.0 23.5 G    r    e    a    t    e    r       A    n    t    i    l    l    e    s
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,Helvetica,black+jLB+a-27 -Gwhite@30 >> $ps << EOF
286.0 23.5 B a h a m a s
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Helvetica,white+jLB+a-350 >> $ps << EOF
276 17.7 Cayman Trough
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Helvetica,white+jLB >> $ps << EOF
293 20 Puerto
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Helvetica,white+jLB+a-8 >> $ps << EOF
296 19.9 Rico
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Helvetica,white+jLB+a-25 >> $ps << EOF
298 19.4 Trench
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f7p,Helvetica,white+jLB >> $ps << EOF
282 13 Colombia
282 12 Basin
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f7p,Helvetica,white+jLB >> $ps << EOF
292.5 15.1 Venezuela
292.5 14.1 Basin
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f7p,Helvetica,white+jLB >> $ps << EOF
275.5 20.6 Yucatan
275.5 19.6 Basin
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f7p,Helvetica,brown+jLB+a-85 -Gwhite@40 >> $ps << EOF
296 16 Aves Ridge
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f7p,Helvetica,brown+jLB+a-350 -Gwhite@40 >> $ps << EOF
275.5 18.4 Cayman Ridge
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f6p,Helvetica,brown+jLB -Gwhite@45 >> $ps << EOF
287.1 15.1 Beata
287.1 14.4 Ridge
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f7p,Helvetica,brown+jLB+a-345 -Gwhite@40 >> $ps << EOF
277 15.6 Nicaraguan Rise
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f7p,Helvetica,blue+jLB+a-350 -Gwhite@40 >> $ps << EOF
295.5 8.5 Orinoco
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f7p,Helvetica,red+jLB -Gwhite@40 >> $ps << EOF
284 8.2 Colombia
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f7p,Helvetica,red+jLB -Gwhite@40 >> $ps << EOF
291 8.0 Venezuela
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f7p,Helvetica,red+jLB -Gwhite@40 >> $ps << EOF
273.5 12.5 Nicaragua
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f7p,Helvetica,red+jLB -Gwhite@40 >> $ps << EOF
271.5 14.7 Honduras
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f6p,Helvetica,red+jLB -Gwhite@40 >> $ps << EOF
277.5 8.4 Panama
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f6p,Helvetica,red+jLB+a-15 -Gwhite@40 >> $ps << EOF
274.5 10.2 Costa Rica
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f7p,Helvetica,red+jLB+a-300 -Gwhite@40 >> $ps << EOF
270.5 18.4 Mexico
EOF

# Add GMT logo
gmt logo -Dx6.2/-2.0+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y5.7c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
2.8 4.2 GEBCO global terrain model, 15 arc sec resolution grid
EOF

# Convert to image file using GhostScript
gmt psconvert Bathymetry_CS.ps -A0.5c -E720 -Tj -Z
