#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO dataset (here: Ninety East Ridge, Indian Ocean)
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

#grdcut GEBCO_2019.nc -R65/107/-35/21 -Gner_relief.nc
#grdcut ETOPO1_Ice_g_gmt4.grd -R65/107/-35/21 -Gner_relief.nc

gdalinfo ner_relief.nc -stats
# Minimum=-6857.000, Maximum=3206.000
# Make color palette
# makecpt --help
#gmt makecpt -Cdem3.cpt -V -T-6857/3206 > myocean.cpt
#gmt makecpt -Cdem2.cpt -V -T-6857/3206 > myocean.cpt
#gmt makecpt -Cgeo.cpt -V -T-6857/3206 > myocean.cpt
gmt makecpt -Crelief.cpt -V -T-6857/3206 > myocean.cpt

# Generate a file
ps=Bathymetry_NER.ps
# Make raster image
gmt grdimage ner_relief.nc -Cmyocean.cpt -R65/107/-35/21 -JM6i -P -I+a15+ne0.75 -Xc -K > $ps
#gmt grdimage ner_relief.nc -Cmyocean.cpt -R65/107/-35/21 -JA110/-5/15/6i -P -I+a15+ne0.75 -Xc -K > $ps

# Add grid
gmt psbasemap -R -J \
    -Bpx10f5a5 -Bpyg10f5a5 -Bsxg5 -Bsyg5 \
    --MAP_TITLE_OFFSET=0.8c \
    --FONT_ANNOT_PRIMARY=7p,Helvetica,black \
    -B+t"Bathymetric map of the Ninety East Ridge region, Indian Ocean" -O -K >> $ps
    
# Add shorelines
gmt grdcontour ner_relief.nc -R -J -C1000 -W0.1p -O -K >> $ps
    
# Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=8p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=8p,Helvetica,black \
    --MAP_LABEL_OFFSET=0.1c \
    -Lx12.7c/-2.5c+c50+w1000k+l"Mercator projection. Scale: km"+f \
    -UBL/-5p/-75p -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P \
    -Ia/thinnest,blue -Na -N1/thinner,red -W0.1p -Df -O -K >> $ps

# Add legend
gmt psscale -Dg65/-38+w15.2c/0.4c+h+o0.0/0i+ml -R -J -Cmyocean.cpt \
    --FONT_LABEL=6p,Helvetica,black \
    --MAP_LABEL_OFFSET=0.1c \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,black \
    -Baf+l"Color scale 'relief': Wessel/Martinez colors for topography [R=-6857/3206, H=0, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps

# Add GMT logo
gmt logo -Dx6.2/-3.5+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y13.0c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
3.0 13.5 GEBCO 15 arc sec resolution global terrain model grid
EOF

# Convert to image file using GhostScript
gmt psconvert Bathymetry_NER.ps -A1.0c -E720 -Tj -Z
