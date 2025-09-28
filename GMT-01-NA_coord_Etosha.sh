#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: Namibia)
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert
# http://soliton.vm.bytemark.co.uk/pub/cpt-city/esri/hillshade/tn/illumination.png.index.html

exec bash

# Extract a subset of ETOPO1m for the study area
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R15/17.5/-20/-17.5 -Gna1_relief_Etosha.nc
gmt grdcut GEBCO_2023.nc -R15/17.5/-20/-17.5 -Gna_relief_Etosha.nc
gmt grdinfo -M na_relief_Etosha.nc
# Minimum=-5033.000, Maximum=2477.000, Mean=458.513, StdDev=1364.345

# Make color palette
#gmt makecpt -Cgeo -V -T-4430/2533 > pauline.cpt
#gmt makecpt -Cturbo -V -T-4430/2533 > pauline.cpt
#gmt makecpt -Cetopo1 -V -T-4430/2533  > pauline.cpt
#gmt makecpt -Cterra -V -T-4430/2533 > pauline.cpt
#gmt makecpt -Cearth -V -T-5033/2477 > pauline.cpt
#gmt makecpt -Cdem1 -V -T-4430/2533 > pauline.cpt

# gmt makecpt -Cafrikakarte -V -T-3395/1000 > pauline.cpt
# gmt makecpt -Cillumination -V -T-5000/500 -Ic > pauline.cpt
# gmt makecpt -Cwiki-1.02.cpt -V -T-3000/500 > pauline.cpt
gmt makecpt -CgrayC -V -T1042/2035 > pauline.cpt
# elevation etopo1 world elevation dem1 dem2 dem3 globe geo srtm turbo terra earth

#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R15/17.5/-20/-17.5 -JM6.5i -Dh -M -ENA > Namibia.txt
#####################################################################

ps=Topo_NA_Etosha.ps
# Make background transparent image
gmt grdimage na_relief_Etosha.nc -Cpauline.cpt -R15/17.5/-20/-17.5 -JM6.5i -I+a15+ne0.75 -t40 -Xc -P -K > $ps

# Add isolines
gmt grdcontour na1_relief_Etosha.nc -R -J -C500 -A1000+f7p,26,darkbrown -Wthinner,darkbrown -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -W0.1p -Df -O -K >> $ps
# Add lakes
# gmt pscoast -R -J -Ia/thinner,blue -Na -Sroyalblue1 -W2/thin,blue,0.1p -Df -O -K >> $ps
    
# Add color legend
gmt psscale -Dg7.8/-30+w15.3c/0.15i+v+o0.3/0i+ml+e -R -J -Cpauline.cpt \
    --FONT_LABEL=9p,0,black \
    --FONT_ANNOT_PRIMARY=9p,0,black \
    --FONT_TITLE=10p,0,black \
    -Bg1000f100a1000 \
    -I0.2 -By+l"m" -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=WESN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    --MAP_FRAME_PEN=dimgray \
    --MAP_FRAME_WIDTH=0.1c \
    --MAP_TITLE_OFFSET=0.7c \
    --FONT_ANNOT_PRIMARY=12p,0,black \
    --FONT_LABEL=80,25,black \
    --FONT_TITLE=12p,0,black \
        -Bpxg2f0.2a0.5 -Bpyg2f0.2a0.5 -Bsxg2 -Bsyg1 -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=12p,0,black \
    --FONT_ANNOT_PRIMARY=10p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    --FONT_TITLE=12p,0,black \
    -Tdx1.0c/15.0c+w0.4i+f2+l+o0.15i \
    -Lx14.7c/-1.5c+c10+w100k+l"Mercator projection. Scale (km)"+f \
    -UBL/0p/-40p -O >> $ps

# Convert to image file using GhostScript
gmt psconvert Topo_NA_Etosha.ps -A0.5c -E720 -Tj -Z
