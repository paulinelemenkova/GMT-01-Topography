#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: Liberia)
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert
# http://soliton.vm.bytemark.co.uk/pub/cpt-city/esri/hillshade/tn/illumination.png.index.html

exec bash

# Extract a subset of ETOPO1m for the study area
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R-13.5/-10/6.8/10.2 -Gsl1_relief.nc
gmt grdcut GEBCO_2023.nc -R-13.5/-10/6.8/10.2 -Gsl_relief.nc
gmt grdinfo -M sl_relief.nc
#gdalinfo -stats sl_relief.nc
# Topography: Minimum=-4304.000, Maximum=1637.000, Mean=-360.606, StdDev=1311.081

# Make color palette
gmt makecpt -Cgeo -V -T-4304/1637 > pauline.cpt
# elevation etopo1 world elevation dem1 dem2 dem3 globe geo srtm turbo terra earth

#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R-13.5/-10/6.8/10.2 -JM6.5i -Dh -M -ESL > SierraLeone.txt
#####################################################################

ps=Topo_SL.ps
# Make background transparent image
gmt grdimage sl_relief.nc -Cpauline.cpt -R-13.5/-10/6.8/10.2 -JM6.5i -I+a15+ne0.75 -t40 -Xc -P -K > $ps

# Add isolines
gmt grdcontour sl1_relief.nc -R -J -C250 -A500+f7p,26,darkbrown -Wthinner,darkbrown -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps
# Add lakes
# gmt pscoast -R -J -Ia/thinner,blue -Na -Sroyalblue1 -W2/thin,blue,0.1p -Df -O -K >> $ps
    
#------------------------->
# CLIPPING
# 1. Start: clip the map by mask to only include country
gmt psclip -R-13.5/-10/6.8/10.2 -JM6.5i SierraLeone.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage sl_relief.nc -Cpauline.cpt -R-13.5/-10/6.8/10.2 -JM6.5i -I+a15+ne0.75 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour sl1_relief.nc -R -J -C250 -A500+f7p,26,darkbrown -Wthinnest,darkbrown -O -K >> $ps
# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps
# add lakes
gmt pscoast -R -J -Ia/thinner,blue -Na -Sroyalblue1 -W2/thin,blue,0.1p -Df -O -K >> $ps

# 3: Undo the clipping
gmt psclip -C -O -K >> $ps
#-------------------------<
    
# Add color legend
gmt psscale -Dg-14.0/6.8+w15.5c/0.15i+v+o0.3/0i+ml+e -R -J -Cpauline.cpt \
    --FONT_LABEL=9p,0,black \
    --FONT_ANNOT_PRIMARY=9p,0,black \
    --FONT_TITLE=8p,0,black \
    -Bg1000f100a1000+l"Colormap: 'geo', colors for global bathymetry/topography relief [R=-4304/16370, H, C=RGB]" \
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
    -B+t"Topographic map of Sierra Leone" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=9p,0,black \
    --FONT_ANNOT_PRIMARY=9p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx14.0c/-1.3c+c10+w100k+l"Mercator projection. Scale (km)"+f \
    -UBL/0p/-30p -O -K >> $ps

#Texts
# cities -R-13.5/-10/6.8/10.2
gmt pstext -R -J -N -O -K \
-F+f16p,0,ivory+jLB >> $ps << EOF
-13.13 8.40 Freetown
EOF
gmt psxy -R -J -Sa -W0.5p -Gred -O -K << EOF >> $ps
-13.23 8.48 0.65c
EOF
gmt pstext -R -J -N -O -K \
-F+f14p,0,ivory+jLB >> $ps << EOF
-11.76 7.92 Bo
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-11.80 7.90 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f14p,0,black+jLB -Gwhite@60 >> $ps << EOF
-11.15 7.95 Kenema
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-11.19 7.87 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f14p,0,ivory+jLB >> $ps << EOF
-11.84 8.93 Makeni
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-12.04 8.88 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f14p,0,ivory+jLB >> $ps << EOF
-10.93 8.54 Koidu
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-10.97 8.64 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f14p,0,ivory+jLB >> $ps << EOF
-12.55 8.58 Lunsar
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-12.53 8.68 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f14p,0,ivory+jLB >> $ps << EOF
-12.79 8.80 Port Loko
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-12.79 8.76 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f14p,0,black+jLB -Gwhite@60 >> $ps << EOF
-11.20 7.71 Pandebu-
-11.20 7.61 Tokpombu
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-10.82 7.58 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f14p,0,ivory+jLB >> $ps << EOF
-11.55 9.63 Kabala
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-11.55 9.58 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f14p,0,ivory+jLB >> $ps << EOF
-11.94 8.63 Magburaka
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-11.94 8.72 0.20c
EOF
# geography
gmt pstext -R -J -N -O -K \
-F+f14p,23,white+jLB >> $ps << EOF
-13.3 7.1 A T L A N T I C
-13.3 6.9 O C E A N
EOF
# insert map
# Countries codes: ISO 3166-1 alpha-2. Continent codes AF (Africa), AN (Antarctica), AS (Asia), EU (Europe), OC (Oceania), NA (North America), or SA (South America). -EEU+ggrey
gmt psbasemap -R -J -O -K -DjTR+w3.5c+o-0.2c/-0.2c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thinnest,lightgray --MAP_FRAME_PEN=thick,white -Rg -JG-1.0/8.0N/$w -Da -Glightgoldenrod1 -A5000 -Bga -Wfaint -ELR+gred -Sroyalblue1 -O -K -X$x0 -Y$y0 >> $ps
#gmt pscoast -Rg -JG12/5N/$w -Da -Gbrown -A5000 -Bg -Wfaint -ECM+gbisque -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx7.0/-1.8+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y9.5c -N -O \
    -F+f11p,0,black+jLB >> $ps << EOF
2.5 11.0 Digital elevation data: SRTM/GEBCO, 15 arc sec resolution grid
EOF

# Convert to image file using GhostScript
gmt psconvert Topo_SL.ps -A0.5c -E720 -Tj -Z
