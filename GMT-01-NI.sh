#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO dataset (here: Nicaragua)
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
# Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults

chsh -s /bin/bash

chsh -s /bin/zsh

gmt grdcut GEBCO_2019.nc -R271.5/278.0/10.5/15.5 -Gni_relief.nc
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R271.5/278.0/10.5/15.5 -Gni_relief1.nc

gdalinfo ni_relief.nc -stats
# Minimum=-5769.354, Maximum=3215.328, Mean=-381.936, StdDev=1333.337

#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R271.5/278.0/10.5/15.5 -Dh -M -ENI > ni.txt
#####################################################################

# Make color palette
# makecpt --help
#gmt makecpt -Cgeo.cpt -V -T-6644/3739 > pauline.cpt
gmt makecpt -Cgeo.cpt -V -T-5770/3216 > pauline.cpt

# Generate a file
ps=Topography_NI.ps
# Make background transparent image
gmt grdimage ni_relief.nc -Cpauline.cpt -R271.5/278.0/10.5/15.5 -JM6.0i -P -I+a15+ne0.75 -t30 -Xc -K > $ps
    
# Add isolines
gmt grdcontour ni_relief1.nc -R -J -C200 -W0.1p -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P \
    -Ia/thinner,blue -Na -N1/thicker,darkred -W0.1p -Df -O -K >> $ps
    
#####################################################################
# CLIPPING
# 1. Start: clip the map by mask to only include country

gmt psclip -R271.5/278.0/10.5/15.5 -JM6.0i ni.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage ni_relief.nc -Cpauline.cpt -R271.5/278.0/10.5/15.5 -JM6.0i -I+a15+ne0.75 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour ni_relief1.nc -R -J -C100 -Wthinnest,darkbrown -O -K >> $ps
# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,darkred -W0.1p -Df -O -K >> $ps

# 3: Undo the clipping
gmt psclip -C -O -K >> $ps
#####################################################################

# Add color barlegend
gmt psscale -Dg271.5/10.10+w15.3c/0.4c+h+o0.0/0i+ml -R -J -Cpauline.cpt \
    --FONT_LABEL=8p,Helvetica,black \
    --MAP_LABEL_OFFSET=0.1c \
    --FONT_ANNOT_PRIMARY=6p,0,black \
    -Baf+l"Color scale 'geo': global bathymetry/topography relief [R=-6857/3206, H=0, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=WEsN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    --MAP_TITLE_OFFSET=0.6c \
    --FONT_TITLE=13p,0,black \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    -Bpx1f0.5a1 -Bpyg1f0.5a0.5 -Bsxg0.5 -Bsyg0.5 \
    -B+t"Topographic map of Nicaragua" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=6p,0,black \
    --MAP_LABEL_OFFSET=0.1c \
    -Lx13.6c/-2.1c+c50+w100k+l"Mercator projection. Scale: km"+f \
    -UBL/-5p/-60p -O -K >> $ps
    
# Texts

# insert map
# Countries codes: ISO 3166-1 alpha-2. Continent codes AF (Africa), AN (Antarctica), AS (Asia), EU (Europe), OC (Oceania), NA (North America), or SA (South America). -EEU+ggrey

gmt psbasemap -R -J -O -K -DjTL+w3.0c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thinnest,white -Rg -JG270/16N/$w -Da -Gkhaki2 -A5000 -Bg -Wfaint -ESA+gpeachpuff -ENI+gindianred4 -Sskyblue2 -O -K -X$x0 -Y$y0 >> $ps
gmt psbasemap -R -J \
    -D267/8/281/17r -F+pthin,red \
    -O -K >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps


# Add GMT logo
gmt logo -Dx6.2/-2.8+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y5.2c -N -O \
    -F+f11p,0,black+jLB >> $ps << EOF
1.7 11.0 SRTM/GEBCO 15 arc sec resolution global terrain model grid
EOF

# Convert to image file using GhostScript
gmt psconvert Topography_NI.ps -A0.5c -E720 -Tj -Z
