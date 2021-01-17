#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: Lebanon)
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
    FONT_ANNOT_PRIMARY=7p,0,dimgray \
    FONT_LABEL=7p,0,dimgray \
# Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults

# Extract a subset of ETOPO1m for the study area
#gmt grdcut ETOPO1_Ice_g_gmt4.grd -R34.7/36.7/32.8/34.8 -Glb_relief.nc
gmt grdcut GEBCO_2019.nc -R34.7/36.7/32.8/34.8 -Glb_relief.nc
gdalinfo -stats lb_relief.nc
# Minimum=-2007.000, Maximum=2973.000

# Make color palette
gmt makecpt -Cworld.cpt -V -T-2020/2973 > myocean.cpt
# elevation etopo1 world elevation

#####################################################################
# create mask of vector layer from the DCW of country's polygon
#gmt pscoast -R34.7/36.7/32.8/34.8 -JM6.5i -Dh -M -ELB > Lebanon.txt
gmt pscoast -Dh -M -ELB > Lebanon.txt
#####################################################################

ps=Topo_LB.ps
# Make background transparent image
gmt grdimage lb_relief.nc -Cmyocean.cpt -R34.7/36.7/32.8/34.8 -JM6.5i -I+a15+ne0.75 -t60 -Xc -P -K > $ps
    
# Add isolines
gmt grdcontour lb_relief.nc -R -J -C100 -A200 -Wthinner,darkbrown -O -K >> $ps

# Add coastlines, borders, rivers
#gmt pscoast -R -J -P \
    -Ia/thinner,blue -Na -N1/thickest,white -W0.1p -Df -O -K >> $ps
gmt pscoast -R -J -P \
    -Ia/thinner,blue -Na -W0.1p -Df -O -K >> $ps

#####################################################################
# CLIPPING
# 1. Start: clip the map by mask to only include country
#gmt psclip -JM -R Lebanon.txt -O -K >> $ps

gmt psclip -R34.7/36.7/32.8/34.8 -JM6.5i Lebanon.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage lb_relief.nc -Cmyocean.cpt -R34.7/36.7/32.8/34.8 -JM6.5i -I+a15+ne0.75 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour lb_relief.nc -R -J -C500 -Wthinner,darkbrown -O -K >> $ps
# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thick,red -W0.1p -Df -O -K >> $ps

# 3: Undo the clipping
gmt psclip -C -O -K >> $ps
#####################################################################

# Add color legend
gmt psscale -Dg34.7/32.68+w16.7c/0.15i+h+o0.0/0i+ml -R -J -Cmyocean.cpt \
    --FONT_LABEL=7p,0,black \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_TITLE=6p,0,black \
    -Bg500f50a500+l"Color scale: 'world' colors for bathymetry/topography [R=-2020/2973, H=0, C=HSV]" \
    -I0.2 -By+lm -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=WEsN \
    --FORMAT_GEO_MAP=ddd:mm:ss \
    --MAP_TITLE_OFFSET=0.8c \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_LABEL=7p,25,black \
    --FONT_TITLE=16p,13,black \
    -Bpxg1f0.1a0.5 -Bpyg0.5f0.1a0.25 -Bsxg1 -Bsyg1 \
    -B+t"Topographic map of Lebanon" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx14.5c/-2.4c+c10+w50k+l"Mercator projection. Scale (km)"+f \
    -UBL/-10p/-70p -O -K >> $ps

# Texts
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,26,blue2+jLB >> $ps << EOF
34.9 34.3 M e d i t e r r a n e a n
35.1 34.2 S e a
EOF
# cities
gmt pstext -R -J -N -O -K \
-F+f13p,13,black+jLB -Gwhite@30 >> $ps << EOF
35.51 33.90 Beiruth
EOF
gmt psxy -R -J -Ss -W0.5p -Gred -O -K << EOF >> $ps
35.51 33.87 0.40c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,black+jLB -Gwhite@30 >> $ps << EOF
36.4 34.32 Halba
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
36.4 34.30 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,black+jLB -Gwhite@30 >> $ps << EOF
36.05 34.02 Baalbek
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
36.12 34.0 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,black+jLB -Gwhite@30 >> $ps << EOF
35.47 33.40 Joub Jannine
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
35.47 33.38 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,black+jLB -Gwhite@30 >> $ps << EOF
35.53 33.30 Rashaya
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
35.5 33.30 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,black+jLB -Gwhite@30 >> $ps << EOF
35.4 33.52 Baabda
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
35.4 33.50 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,black+jLB -Gwhite@30 >> $ps << EOF
35.29 33.23 Nabatieh
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
35.29 33.21 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,black+jLB -Gwhite@30 >> $ps << EOF
35.83 34.47 Tripoli
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
35.83 34.45 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,black+jLB -Gwhite@30 >> $ps << EOF
35.25 33.35 Sidon
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
35.24 33.33 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,black+jLB -Gwhite@30 >> $ps << EOF
35.20 33.19 Tyre
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
35.18 33.17 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,black+jLB -Gwhite@30 >> $ps << EOF
35.57 33.48 Zahlé
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
35.55 33.50 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,black+jLB -Gwhite@30 >> $ps << EOF
35.37 33.33 Jezzine
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
35.35 33.32 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,25,white+jLB+a-300 -Gsaddlebrown@40 >> $ps << EOF
35.95 34.02 Lebanon  Mts
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,25,darkbrown+jLB+a-310 -Gwhite@50 >> $ps << EOF
35.85 33.7 Beqaa Valley
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,25,white+jLB+a-310 -Gsaddlebrown@40 >> $ps << EOF
36.25 33.9 Anti-Lebanon Mts
EOF

# Add GMT logo
gmt logo -Dx7.0/-3.0+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.1c -Y14.4c -N -O \
    -F+f10p,13,black+jLB >> $ps << EOF
3.0 9.0 Digital elevation data: SRTM/GEBCO, 15 arc sec resolution grid
EOF

# Convert to image file using GhostScript
gmt psconvert Topo_LB.ps -A1.5c -E720 -Tj -Z
