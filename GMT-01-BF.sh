#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: Burkina Faso)
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
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R-6/3/9/15.5 -Gbf1_relief.nc
gmt grdcut GEBCO_2019.nc -R-6/3/9/15.5 -Gbf_relief.nc
gdalinfo -stats bf1_relief.nc
# Topography: Minimum=29.000, Maximum=896.000, Mean=288.667, StdDev=65.948

# Make color palette
gmt makecpt -Cearth -V -T29/896 > pauline.cpt
# elevation etopo1 world elevation dem1 dem2 dem3 globe geo srtm turbo terra earth

#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R-6/3/9/15.5 -JM5.5i -Dh -M -EBF > BurkinaFaso.txt
#####################################################################

ps=Topo_BF.ps
# Make background transparent image
gmt grdimage bf_relief.nc -Cpauline.cpt -R-6/3/9/15.5 -JM5.5i -I+a15+ne0.75 -t40 -Xc -P -K > $ps
    
# Add isolines
gmt grdcontour bf1_relief.nc -R -J -C1000 -A1000+f7p,26,darkbrown -Wthinner,darkbrown -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thick,dimgray -W0.1p -Df -O -K >> $ps
    
#####################################################################
# CLIPPING
# 1. Start: clip the map by mask to only include country

gmt psclip -R-6/3/9/15.5 -JM5.5i BurkinaFaso.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage bf_relief.nc -Cpauline.cpt -R-6/3/9/15.5 -JM5.5i -I+a15+ne0.75 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour bf1_relief.nc -R -J -C500 -Wthinnest,darkbrown -O -K >> $ps
# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thick,tomato -W0.1p -Df -O -K >> $ps
#gmt pscoast -R -J \
    -Ia/thinner,blue -Na -W0.1p -Df -O -K >> $ps

# 3: Undo the clipping
gmt psclip -C -O -K >> $ps
#####################################################################
    
# Add color legend
gmt psscale -Dg-6.3/8.2+w14.0c/0.15i+h+o0.3/0i+ml+e -R -J -Cpauline.cpt \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_TITLE=6p,0,black \
    -Bg50f5a100+l"Colormap: 'earth' Colors for global topography relief [R=-T29/896, H, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=WEsN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    --MAP_TITLE_OFFSET=0.7c \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --FONT_LABEL=8p,25,black \
    --FONT_TITLE=13p,0,black \
        -Bpxg2f1a1 -Bpyg2f1a1 -Bsxg2 -Bsyg1 \
    -B+t"Topographic map of Burkina Faso" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx11.7c/-2.4c+c10+w250k+l"Mercator projection. Scale (km)"+f \
    -UBL/0p/-70p -O -K >> $ps

# Texts
# Cities -R-6/3/9/15.5
#
# countries
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,25,black+jLB >> $ps << EOF
-5.8 14.7 M  A  L  I
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,25,black+jLB -Gwhite@75 >> $ps << EOF
1.2 13.5 N   I   G   E   R
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,25,black+jLB -Gwhite@75 >> $ps << EOF
1.2 10.5 B   E   N   I   N
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,25,black+jLB -Gwhite@75 >> $ps << EOF
0.4 9.7 T O G O
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,25,black+jLB -Gwhite@75 >> $ps << EOF
-1.8 9.5 G  H  A  N  A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,25,black+jLB -Gwhite@75 >> $ps << EOF
-5.5 9.2 C Ô T E  D\'I V O I R E
EOF
#
gmt pstext -R -J -N -O -K \
-F+jTL+f17p,29,white+jLB >> $ps << EOF
-3.4 12.5 B U R K I N A   F A S O
EOF
# water

# insert map
# Countries codes: ISO 3166-1 alpha-2. Continent codes AF (Africa), AN (Antarctica), AS (Asia), EU (Europe), OC (Oceania), NA (North America), or SA (South America). -EEU+ggrey
gmt psbasemap -R -J -O -K -DjTR+w2.7c+o-0.2c/-0.2c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thin,grey -Rg -JG-1.0/8.0N/$w -Da -Glightgoldenrod1 -A5000 -Bga -Wfaint -EBF+gred -Sdodgerblue -O -K -X$x0 -Y$y0 >> $ps
#gmt pscoast -Rg -JG12/5N/$w -Da -Gbrown -A5000 -Bg -Wfaint -ECM+gbisque -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx6.0/-3.1+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y4.0c -N -O \
    -F+f10p,0,black+jLB >> $ps << EOF
01.5 10.4 Digital elevation data: SRTM/GEBCO, 15 arc sec resolution grid
EOF

# Convert to image file using GhostScript
gmt psconvert Topo_BF.ps -A0.5c -E720 -Tj -Z
