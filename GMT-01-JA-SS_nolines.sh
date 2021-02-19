#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO global data set (here: Scotia Sea)
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert

# Step-2. GMT set up
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
# Step-3. Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults

#gmt grdcut ETOPO1_Ice_g_gmt4.grd -R270/371/-72/-44 -Gss_relief.nc
gmt grdcut GEBCO_2019.nc -R270/371/-72/-44 -Gss_relief.nc

gdalinfo -stats ss_relief.nc
#  Min=-8239.000 Max=6392.000
# Step-5. Make color palette
gmt makecpt -Cgeo.cpt -V -T-8239/6392 > myocean.cpt
#makecpt --help

# Generate a file
ps=Bathymetry_SS.ps
gmt grdimage ss_relief.nc -Cmyocean.cpt -R270/-65/340/-45r -JA318/-57/5.5i -P -I+a15+ne0.75 -Xc -K > $ps

# Add shorelines
gmt grdcontour ss_relief.nc -R -J -C2000 -W0.1p -O -K >> $ps

# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=wESN \
    -Bpxf5a10 -Bpyf5a5 \
    --MAP_TITLE_OFFSET=1.5c \
    --MAP_ANNOT_OFFSET=0.1c \
    --MAP_LABEL_OFFSET=0.1c \
    --FONT_ANNOT_PRIMARY=7p,Helvetica,black \
    --FONT_LABEL=8p,Helvetica,black \
    -Lx12.0c/-1.3c+c318/-57+w1000k+f \
    -O -K >> $ps
# -Bpx10f5a10 -Bpyg10f5a5 -Bsxg5 -Bsyg5 \

# Add legend
gmt psscale -Dg269/-68+w10.0c/0.4c+v+o-7.0c/-5.3c+ml -R270/340/-65/-45 -J -Cmyocean.cpt \
    --FONT_LABEL=7p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,black \
    -Bg1000f200a2000 \
    -I0.2 -By+lm -O >> $ps

# Convert to image file using GhostScript
gmt psconvert Bathymetry_SS.ps -A0.5c -E720 -Tj -Z
