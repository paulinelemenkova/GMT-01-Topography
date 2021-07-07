#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: Sweden)
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert
# http://soliton.vm.bytemark.co.uk/pub/cpt-city/njgs/index.html

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
    FONT_ANNOT_PRIMARY=7p,0,dimgray \
    FONT_LABEL=7p,0,dimgray \
# Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults

# Extract a subset of ETOPO1m for the study area
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R4/16/54/60 -Gse_kat_relief1.nc
gmt grdcut GEBCO_2019.nc -R4/16/54/60 -Gse_kat_relief.nc
gdalinfo -stats se_kat_relief.nc
# Minimum=-698.000, Maximum=1603.000, Mean=4.757, StdDev=225.299

# Make color palette
#gmt makecpt -Cgeo -V -T-698/1603 > pauline.cpt
#gmt makecpt -Carctic -V -T-698/1603 > pauline.cpt
#gmt makecpt -Cibcao -V -T-698/1603 > pauline.cpt
#gmt makecpt -CETOPO1 -V -T-698/1603 > pauline.cpt
#gmt makecpt -Cworld -V -T-698/1603 > pauline.cpt
#gmt makecpt -Cturbo -V -T-698/1603 > pauline.cpt
gmt makecpt -Cglobe -V -T-698/1603 > pauline.cpt
# elevation etopo1 world dem1 dem2 dem3 globe geo srtm turbo terra earth relief costa-rica

ps=Topo_SEkat.ps
# Make background transparent image
gmt grdimage se_kat_relief.nc -Cpauline.cpt -R4/16/54/60 -JM5.0i -I+a15+ne0.75 -t0 -Xc -P -K > $ps
    
# Add isolines
gmt grdcontour se_kat_relief1.nc -R -J -C250 -A500+f7p,26,darkbrown -Wthinner,darkbrown -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,red -W0.1p -Df -O -K >> $ps
    
# Add color legend
gmt psscale -Dg4.0/53.3+w12.0c/0.15i+h+o0.3/0i+ml+e -R -J -Cpauline.cpt \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_TITLE=6p,0,black \
    -Bg250f25a250+l"Colormap: 'globe' scheme for bathymetry/topography. [R=-698/1603, H, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=WEsN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    -Bpxg2f2a2 -Bpyg2f1a1 -Bsxg2 -Bsyg2 \
    --MAP_TITLE_OFFSET=0.8c \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --FONT_LABEL=8p,25,black \
    --FONT_TITLE=14p,25,black \
    -B+t"Topographic map of the Skagerrak and Kattegat straits region" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx10.5c/-2.5c+c10+w400k+l"Mercator Projection. Scale (km)"+f \
    -UBL/0p/-70p -O -K >> $ps

# Texts
# countries
gmt pstext -R -J -N -O -K \
-F+jTL+f13p,25,black+jLB -Gwhite@60 >> $ps << EOF
12.2 58.8 S  W  E  D  E  N
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f13p,25,black+jLB -Gwhite@60 >> $ps << EOF
6.2 59.1 N O R W A Y
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,25,black+jLB -Gwhite@60 >> $ps << EOF
8.3 56.1 DENMARK
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,25,black+jLB -Gwhite@60 >> $ps << EOF
8.9 54.15 GERMANY
EOF

# Sea
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,26,darkviolet+jLB+a-65 >> $ps << EOF
10.7 58.0 Kattegat Strait
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,26,darkviolet+jLB+a-330 >> $ps << EOF
7.4 57.0 Skagerrak Strait
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,26,blue2+jLB >> $ps << EOF
5.0 56.2 North
5.2 55.8 Sea
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,26,blue2+jLB >> $ps << EOF
14.2 54.7 Baltic
14.4 54.4 Sea
EOF

# Cities
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB+a-0 -Gwhite@60 >> $ps << EOF
12.07 57.50 Gothenburg
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
11.97 57.70 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@60 >> $ps << EOF
12.82 56.15 Helsingborg
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
12.72 56.05 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@60 >> $ps << EOF
13.10 55.48 Malmö
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
13.04 55.61 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,0,darkbrown+jLB >> $ps << EOF
13.00 56.6 Halland
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,0,darkbrown+jLB >> $ps << EOF
12.00 58.2 Bohuslän
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB+a-0 -Gwhite@60 >> $ps << EOF
10.8 59.75 Oslo
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
10.8 59.90 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB+a-0 -Gwhite@60 >> $ps << EOF
12.60 55.70 Copenhagen
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
12.56 55.67 0.20c
EOF

# Add GMT logo
gmt logo -Dx4.5/-3.1+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.c -Y6.5c -N -O \
    -F+f10p,0,black+jLB >> $ps << EOF
1.0 9.0 Digital elevation data: GEBCO grid, 15 arc sec (ca. 450 m) resolution
EOF

# Convert to image file using GhostScript
gmt psconvert Topo_SEkat.ps -A0.5c -E720 -Tj -Z
