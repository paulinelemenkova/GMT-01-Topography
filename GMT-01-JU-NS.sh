#!/bin/sh
# Purpose: GEBCO global bathymetry dataset (here: North Sea, Atlantic Ocean)
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, pscoast, pstext, gmtlogo, psconvert

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

grdcut GEBCO_2019.nc -R-7/15/50/63 -Gns_relief.nc
gdalinfo ns_relief.nc -stats
# Minimum=-2273.947, Maximum=2344.548

# Select a color palette
#gmt makecpt -Cglobe.cpt -V -T-2274/2345 > myocean.cpt
gmt makecpt -Cgeo.cpt -V -T-2274/2345 > myocean.cpt

# Generate a file
ps=Bathymetry_NS.ps

# Make raster image
#gmt grdimage GEBCO_2019.nc -Cmyocean.cpt -R-7/15/50/63 -JM5.5i -P -I+a15+ne0.75 -Xc -K > $ps
#gmt grdimage ETOPO1_Ice_g_gmt4.grd -Cmyocean.cpt -R-7/15/50/63 -JM5.5i -P -I+a15+ne0.75 -Xc -K > $ps
#gmt grdimage ETOPO1_Ice_g_gmt4.grd -Cmyocean.cpt -R-7/15/50/63 -JPoly/5.5i -P -I+a15+ne0.75 -Xc -K > $ps
#gmt grdimage ETOPO1_Ice_g_gmt4.grd -Cmyocean.cpt -R-7/15/50/63 -Js4/90/5.5i/60 -P -I+a15+ne0.75 -Xc -K > $ps
#gmt grdimage ETOPO1_Ice_g_gmt4.grd -Cmyocean.cpt -R-7/15/50/63 -JU31/5.5i -P -I+a15+ne0.75 -Xc -K > $ps
gmt grdimage GEBCO_2019.nc -Cmyocean.cpt -R-7/15/50/63 -JU31/5.5i -P -I+a15+ne0.75 -Xc -K > $ps

# Add grid
gmt psbasemap -R -J \
    --MAP_TITLE_OFFSET=0.7c \
    --MAP_FRAME_AXES=WESN \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,black \
    --FONT_LABEL=6p,Helvetica,black \
    -Bpxg4f2a4 -Bpyg8f4a2 -Bsxg2 -Bsyg2 \
    -B+t"Bathymetric map of the North Sea, Atlantic Ocean" -O -K >> $ps
    
# Add shorelines
#gmt grdcontour GEBCO_2019.nc -R -J -C1000 -Wthinnest,dimgray -O -K >> $ps
gmt grdcontour ETOPO1_Ice_g_gmt4.grd -R -J -C1000 -Wthinnest,dimgray -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P -Ia/thinner,blue -Na -N1/thick,red -W0.2p -Df -O -K >> $ps

# Add scale     #FONT_LABEL=7p,Helvetica,dimgray    # --FONT_TITLE=8p,Helvetica,black
gmt psbasemap -R -J \
    --MAP_TITLE_OFFSET=0.1c \
    --FONT_LABEL=8p,Helvetica,black \
    -Lx12.0c/-2.8c+c50+w500k+l"UTM projection. Scale: km"+f \
    -UBL/-5p/-80p -O -K >> $ps

# Add legend
gmt psscale -Dg-7/48+w14.0c/0.4c+h+o0.3/0i+ml -R -J -Cmyocean.cpt \
    --FONT_LABEL=7p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,black \
    -Ba500f100+l"Color scale 'globe': global bathymetry/topography relief [R=-3973/2578, H=0, C=RGB])" \
    -I0.2 -By+lm -O -K >> $ps

# Texts
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,Helvetica,blue+jLB >> $ps << EOF
2 57 NORTH
2.4 56 SEA
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,Helvetica,blue+jLB+a-330 >> $ps << EOF
8 57.5 Skagerrak
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,Helvetica,blue+jLB+a-60 -Gwhite@40 >> $ps << EOF
10.9 57.8 Kattegat
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f7p,Helvetica,black+jLB -Gwhite@40 >> $ps << EOF
6.1 50.9 Luxemburg
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,Helvetica,black+jLB -Gwhite@30 >> $ps << EOF
8.3 56.2 DENMARK
6.5 61 NORWAY
-3.5 55 UNITED
-3.5 52.5 KINGDOM
3.3 50.7 BELGIUM
1.8 50.1 FRANCE
-0.3 60.5 Shetland
-0.4 60.2 Islands
-2.2 59 Orkney
-2.3 58.7 Islands
-6 62 Faroe
-6.2 61.7 Islands
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,Helvetica,black+jLB+a-355 -Gwhite@30 >> $ps << EOF
9.5 51 GERMANY
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,Helvetica,black+jLB+a-315 -Gwhite@30 >> $ps << EOF
4.5 51.5 NETHERLANDS
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,Helvetica,black+jLB+a-355 -Gwhite@30 >> $ps << EOF
12.1 59 SWEDEN
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,Helvetica,blue+jLB+a-318 >> $ps << EOF
0.3 50.1 English Channel
EOF

# Add GMT logo
gmt logo -Dx6.0/-3.3+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y5.0c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
2.1 13.6 GEBCO global terrain model 15 arc sec resolution grid
1.7 13.0 Universal Transverse Mercator zone 31, central meridian 4\232E
EOF

# Convert to image file using GhostScript
gmt psconvert Bathymetry_NS.ps -A0.8c -E720 -Tj -Z
