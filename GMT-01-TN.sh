#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: Algeria)
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert

exec bash

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
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R7/12/30/37.5 -Gtn1_relief.nc
gmt grdcut GEBCO_2019.nc -R7/12/30/37.5 -Gtn_relief.nc
gdalinfo -stats tn1_relief.nc
# Minimum=-2786.000, Maximum=3781.000, Mean=431.959, StdDev=731.000

# Make color palette
gmt makecpt -Cgeo -V -T-2786/3781 > pauline.cpt
# elevation etopo1 world elevation dem1 dem2 dem3 globe geo srtm turbo terra earth

#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R7/12/30/37.5 -JM5.5i -Dh -M -ETN > TN.txt
#####################################################################

ps=Topo_TN.ps
# Make background transparent image

gmt grdimage tn1_relief.nc -Cpauline.cpt -R7/12/30/37.5 -JM5.5i -I+a15+ne0.75 -t40 -Xc -P -K > $ps

# Add isolines
gmt grdcontour tn1_relief.nc -R -J -C250 -A500+f7p,26,darkbrown -Wthinnest,darkbrown -O -K >> $ps

# Add coastlines, borders, rivers, lakes
gmt pscoast -R -J -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps
    
#####################################################################
# CLIPPING
# 1. Start: clip the map by mask to only include country

gmt psclip -R7/12/30/37.5 -JM5.5i TN.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage tn1_relief.nc -Cpauline.cpt -R7/12/30/37.5 -JM5.5i -I+a15+ne0.75 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour tn1_relief.nc -R -J -C200 -A400+f7p,26,darkbrown -Wthinner,darkbrown -O -K >> $ps
# Add coastlines, borders, rivers, lakes
gmt pscoast -R -J -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps

# 3: Undo the clipping
gmt psclip -C -O -K >> $ps
#####################################################################
    
# Add color legend -R7/12/30/37.5
gmt psscale -Dg7/29.6+w13.0c/0.15i+h+o0.3/0i+ml+e -R -J -Cpauline.cpt \
    --FONT_LABEL=10p,0,black \
    --FONT_ANNOT_PRIMARY=10p,0,black \
    --FONT_TITLE=10p,0,black \
    -Bg500f100a1000+l"Colormap: 'geo' Colors for global topography relief [R=-4373/3703, H, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=WEsN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    --MAP_TITLE_OFFSET=0.7c \
    --FONT_ANNOT_PRIMARY=10p,0,black \
    --FONT_LABEL=10p,25,black \
    --FONT_TITLE=14p,0,black \
        -Bpxg4f1a2 -Bpyg4f1a2 -Bsxg1 -Bsyg1 \
    -B+t"Topographic map of Tunisia" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=10p,0,black \
    --FONT_ANNOT_PRIMARY=10p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx12.5c/-2.6c+c10+w125k+l"Mercator projection. Scale (km)"+f \
    -UBL/0p/-70p -O -K >> $ps

# Texts
# countries -R7/12/30/37.5

# insert map
gmt psbasemap -R -J -O -K -DjBL+w5.5c+o-0.2c/-0.2c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thin,grey -Rg -JG10/35N/$w -Da -Glightgoldenrod1 -A5000 -Bga -Wfaint -ETN+gred -Sroyalblue2 -O -K -X$x0 -Y$y0 >> $ps
#gmt pscoast -Rg -JG12/5N/$w -Da -Gbrown -A5000 -Bg -Wfaint -ECM+gbisque -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx7.0/-3.3+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y19.1c -N -O \
    -F+f11p,0,black+jLB >> $ps << EOF
2.0 10.4 Digital elevation data: SRTM/GEBCO, 15 arc sec resolution grid
EOF

# Convert to image file using GhostScript
gmt psconvert Topo_TN.ps -A0.7c -E720 -Tj -Z
