#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: Mali)
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert
# http://soliton.vm.bytemark.co.uk/pub/cpt-city/esri/hillshade/tn/illumination.png.index.html

exec bash

# Extract a subset of ETOPO1m for the study area
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R-12/-6/4/9 -Glr1_relief.nc
gmt grdcut GEBCO_2023.nc -R-12/-6/4/9 -Glr_relief.nc
gmt grdcut GEBCO_2019.nc -R-12/-6/4/9 -Glr_relief.nc
gdalinfo -stats lr_relief.nc
# Topography: Minimum=-4304.000, Maximum=1637.000, Mean=-360.606, StdDev=1311.081

# Make color palette
gmt makecpt -Cgeo -V -T-4304/1637 > pauline.cpt
#gmt makecpt -Cturbo -V -T-4973/1834 > pauline.cpt
# gmt makecpt -Cterra -V -T-3395/1434 > pauline.cpt
# gmt makecpt -Cearth -V -T-3395/1434 > pauline.cpt
# gmt makecpt -Cdem1 -V -T-3395/1434 > pauline.cpt
# gmt makecpt -Cgeo -V -T-3395/1434 > pauline.cpt
# gmt makecpt -Cafrikakarte -V -T-5000/500 > pauline.cpt
# gmt makecpt -Cafrikakarte -V -T-3395/1000 > pauline.cpt
# gmt makecpt -Cillumination -V -T-5000/500 -Ic > pauline.cpt
# gmt makecpt -Cwiki-1.02.cpt -V -T-3000/500 > pauline.cpt
# elevation etopo1 world elevation dem1 dem2 dem3 globe geo srtm turbo terra earth

#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R-12/-6/4/9 -JM6.5i -Dh -M -ELR > Liberia.txt
#####################################################################

ps=Topo_LR.ps
# Make background transparent image
gmt grdimage lr_relief.nc -Cpauline.cpt -R-12/-6/4/9 -JM6.5i -I+a15+ne0.75 -t40 -Xc -P -K > $ps

# Add isolines
gmt grdcontour lr1_relief.nc -R -J -C250 -A500+f7p,26,darkbrown -Wthinner,darkbrown -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps
# Add lakes
# gmt pscoast -R -J -Ia/thinner,blue -Na -Sroyalblue1 -W2/thin,blue,0.1p -Df -O -K >> $ps
    
#------------------------->
# CLIPPING
# 1. Start: clip the map by mask to only include country
gmt psclip -R-12/-6/4/9 -JM6.5i Liberia.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage lr_relief.nc -Cpauline.cpt -R-12/-6/4/9 -JM6.5i -I+a15+ne0.75 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour lr1_relief.nc -R -J -C250 -A500+f7p,26,darkbrown -Wthinnest,darkbrown -O -K >> $ps
# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps
# add lakes
#gmt pscoast -R -J -Ia/thinner,blue -Na -Sroyalblue1 -W2/thin,blue,0.1p -Df -O -K >> $ps

# 3: Undo the clipping
gmt psclip -C -O -K >> $ps
#-------------------------<
    
# Add color legend
gmt psscale -Dg-12.8/4+w13.8c/0.15i+v+o0.3/0i+ml+e -R -J -Cpauline.cpt \
    --FONT_LABEL=9p,0,black \
    --FONT_ANNOT_PRIMARY=9p,0,black \
    --FONT_TITLE=8p,0,black \
    -Bg1000f100a1000+l"Colormap: 'geo', C=RGB" \
    -I0.2 -By+l"m" -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=wEsN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    --MAP_FRAME_PEN=dimgray \
    --MAP_FRAME_WIDTH=0.1c \
    --MAP_TITLE_OFFSET=0.7c \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --FONT_LABEL=8p,25,black \
    --FONT_TITLE=12p,0,black \
        -Bpxg1f0.5a1 -Bpyg1f0.5a1 -Bsxg2 -Bsyg1 \
    -B+t"Topographic map of Liberia" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=9p,0,black \
    --FONT_ANNOT_PRIMARY=9p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx14.0c/-1.3c+c10+w200k+l"Mercator projection. Scale (km)"+f \
    -UBL/0p/-30p -O -K >> $ps

# Study area
# Rotated rectangle. kwargs: coords, direction degrees, x and y-dimension
#gmt psxy -R -J -Sj1c -W1.7p,red3 -O -K << EOF >> $ps
#-16.68 14.46 -13 4.0 4.0
#EOF

# Texts
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,29,black+jLB >> $ps << EOF
-7.2 5.8 C Ô T E
-7.2 5.5 D\' I V O I R E
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,29,gray25+jLB -Gwhite@70 >> $ps << EOF
-11.8 7.8 SIERRA
-11.8 7.5 LEONE
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,29,gray25+jLB -Gwhite@70 >> $ps << EOF
-9.3 8.7 G U I N E A
EOF
# rivers
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,23,blue+jLB+a22 >> $ps << EOF
-10.50 6.90 St. Paul
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,23,blue+jLB+a22 >> $ps << EOF
-9.60 6.50 St. John
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,23,blue+jLB+a35 >> $ps << EOF
-9.50 5.55 Cestos
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,23,blue+jLB+a0 >> $ps << EOF
-7.85 5.70 Dube
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,23,blue+jLB+a24 >> $ps << EOF
-10.80 7.20 Loffa
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,23,blue+jLB+a44 -Gwhite@60 >> $ps << EOF
-10.45 7.65 Gbeya
EOF
gmt pstext -R -J -N -O -K \
-F+f14p,23,white+jLB >> $ps << EOF
-11.7 4.7 A T L A N T I C
-11.7 4.4 O C E A N
EOF
#
# insert map
# Countries codes: ISO 3166-1 alpha-2. Continent codes AF (Africa), AN (Antarctica), AS (Asia), EU (Europe), OC (Oceania), NA (North America), or SA (South America). -EEU+ggrey
gmt psbasemap -R -J -O -K -DjTR+w3.2c+o-0.2c/-0.2c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thinnest,lightgray --MAP_FRAME_PEN=thick,white -Rg -JG-1.0/8.0N/$w -Da -Glightgoldenrod1 -A5000 -Bga -Wfaint -ELR+gred -Sroyalblue1 -O -K -X$x0 -Y$y0 >> $ps
#gmt pscoast -Rg -JG12/5N/$w -Da -Gbrown -A5000 -Bg -Wfaint -ECM+gbisque -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx7.0/-1.8+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y7.3c -N -O \
    -F+f11p,0,black+jLB >> $ps << EOF
2.5 11.0 Digital elevation data: SRTM/GEBCO, 15 arc sec resolution grid
EOF

# Convert to image file using GhostScript
gmt psconvert Topo_LR.ps -A0.5c -E720 -Tj -Z
