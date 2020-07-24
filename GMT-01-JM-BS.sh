#!/bin/sh
# Purpose: geoid grid raster map from the EGM96 global data set (here: Beaufort Sea, Arctic Ocean)
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

grdcut GEBCO_2019.nc -R180/270/66/83 -Gbs_relief.nc
gdalinfo bs_relief.nc -stats
# -3973,2578

# Select a color palette
gmt makecpt -Cglobe.cpt -V -T-3973/2578 > myocean.cpt

# Generate a file
ps=Bathymetry_BS.ps

# Make raster image
gmt grdimage GEBCO_2019.nc -Cmyocean.cpt -R180/270/66/83 -JM5.5i -P -I+a15+ne0.75 -Xc -K > $ps
#gmt grdimage ETOPO1_Ice_g_gmt4.grd -Cmyocean.cpt -R180/270/66/83 -JM5.5i -P -I+a15+ne0.75 -Xc -K > $ps

# Add grid
gmt psbasemap -R -J \
    --MAP_TITLE_OFFSET=0.7c \
    --MAP_FRAME_AXES=wESN \
    -Bpxg10f5a10 -Bpyg10f5a5 -Bsxg5 -Bsyg5 \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,black \
    --FONT_LABEL=6p,Helvetica,black \
    -B+t"Bathymetric map of the Beaufort Sea, Arctic Ocean" -O -K >> $ps
    
# Add shorelines
gmt grdcontour GEBCO_2019.nc -R -J -C1000 -Wthinnest,dimgray -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P -Ia/thinnest,blue -W0.2p -Df -O -K >> $ps
    
# Add scale
gmt psbasemap -R -J \
    --FONT=8p,Palatino-Roman,black \
    --MAP_TITLE_OFFSET=0.3c \
    -Lx12.0c/-1.3c+c50+w2000k+l"Mercator projection. Scale: km"+f \
    -UBL/-5p/-40p -O -K >> $ps

# Add legend
gmt psscale -Dg169/65.9+w11.4c/0.4c+v+o0.3/0i+ml -R -J -Cmyocean.cpt \
    --FONT_LABEL=6p,Helvetica,dimgray \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,black \
    -Ba500f100+l"Color scale 'globe': global bathymetry/topography relief [R=-3973/2578, H=0, C=RGB])" \
    -I0.2 -By+lm -O -K >> $ps

# Texts
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,Helvetica,white+jLB >> $ps << EOF
210.4 82.5 A R C T I C  O C E A N
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,Helvetica,white+jLB >> $ps << EOF
209.7 76.5 B E A U F O R T
216.0 75.5 S E A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,Palatino-Italic,blue+jLB+a-55 >> $ps << EOF
227.0 68.6 Mackenzie
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,Palatino-Italic,blue+jLB+a-60 >> $ps << EOF
234.8 68.5 Anderson
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f7p,Palatino-Roman,black+jLB -Gwhite@40 >> $ps << EOF
240.5 77.0 Queen
240.7 76.4 Elizabeth
240.9 75.7 Islands
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,Palatino-Roman,black+jLB -Gwhite@40 >> $ps << EOF
246 71.0 Victoria
246.5 70.3 Island
235.3 73.0 Banks
235.6 72.3 Island
EOF

# Add GMT logo
gmt logo -Dx6.0/-2.0+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y5.7c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
1.5 9.2 GEBCO/IBCAO global terrain model 15 arc sec resolution grid
EOF

# Convert to image file using GhostScript
gmt psconvert Bathymetry_BS.ps -A0.5c -E720 -Tj -Z
