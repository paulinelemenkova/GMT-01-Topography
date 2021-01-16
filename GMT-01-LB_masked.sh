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
gmt psclip -JM -R Lebanon.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage lb_relief.nc -Cmyocean.cpt -R34.7/36.7/32.8/34.8 -JM6.5i -I+a15+ne0.75 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour lb_relief.nc -R -J -C500 -Wthinner,darkbrown -O -K >> $ps
# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/2pt,red -W0.1p -Df -O -K >> $ps

# 3: Undo the clipping
gmt psclip -C -O -K >> $ps
#####################################################################

# Add color legend
gmt psscale -Dg34.7/32.68+w17.0c/0.15i+h+o0.3/0i+ml -R -J -Cmyocean.cpt \
    --FONT_LABEL=7p,0,black \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_TITLE=6p,0,black \
    -Bg500f50a500+l"Color scale: 'world' [R=-5358/3447, H=0, C=HSV]" \
    -I0.2 -By+lm -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=WEsN \
    --MAP_TITLE_OFFSET=0.8c \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_LABEL=7p,25,black \
    --FONT_TITLE=13p,13,black \
    -Bpxg1f0.1a1 -Bpyg1f0.1a1 -Bsxg1 -Bsyg1 \
    -B+t"Topographic map of Lebanon" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx14.5c/-2.4c+c10+w50k+l"Mercator projection. Scale (km)"+f \
    -UBL/-10p/-70p -O -K >> $ps

# Texts

# Add GMT logo
gmt logo -Dx7.0/-3.0+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.1c -Y14.4c -N -O \
    -F+f10p,13,black+jLB >> $ps << EOF
3.0 9.0 Digital elevation data: SRTM/GEBCO, 15 arc sec resolution grid
EOF

# Convert to image file using GhostScript
gmt psconvert Topo_LB.ps -A1.5c -E720 -Tj -Z
