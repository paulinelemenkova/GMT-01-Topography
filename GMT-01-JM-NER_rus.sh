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
# gmtdefaults -D > .gmtdefaults

gmt grdcut GEBCO_2019.nc -R65/107/-35/21 -Gner_relief.nc
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

# Add grid
gmt psbasemap -R -J \
    -Bpx10f5a5 -Bpyg10f5a5 -Bsxg5 -Bsyg5 \
    --MAP_TITLE_OFFSET=0.8c \
    --FONT_TITLE=14p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=7p,Helvetica,black \
    -O -K >> $ps
    
# Add shorelines
gmt grdcontour ner_relief.nc -R -J -C1000 -W0.1p -O -K >> $ps
    
# Add scale, directional rose
gmt psbasemap -R -J \
    --GMT_LANGUAGE=RU \
    --FONT=10p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=10p,Helvetica,black \
    --MAP_LABEL_OFFSET=0.1c \
    -Lx12.7c/-2.5c+c50+w1000k+f \
    -UBL/-5p/-75p -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P \
    -Ia/thinnest,blue -Na -N1/thinner,red -W0.1p -Df -O -K >> $ps
    
# Rotated rectangle. kwargs: coords (center), direction degrees, x and y-dimension
gmt psxy -R -J -Sj1c -W1.5p,gold -O -K << EOF >> $ps
90.0 0.0 180.0 2 4.5
EOF
gmt psxy -R -J -Sj1c -W1.5p,gold -O -K << EOF >> $ps
88.5 -11.5 180.0 2 3.8
EOF
gmt psxy -R -J -Sj1c -W1.5p,gold -O -K << EOF >> $ps
87.5 -21.5 180.0 2 3.8
EOF

# Add legend
gmt psscale -Dg65/-38+w15.2c/0.4c+h+o0.0/0i+ml -R -J -Cmyocean.cpt \
    --FONT_LABEL=7p,Helvetica,black \
    --MAP_LABEL_OFFSET=0.1c \
    --FONT_ANNOT_PRIMARY=7p,Helvetica,black \
    -Baf \
    -I0.2 -By+lm -O -K >> $ps

# insert map
gmt psbasemap -R -J -O -K -DjTR+w3.5c+o-0.2c/-0.2c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thin,grey \
    -Rg -JG85/10S/$w -Da -Gpeachpuff2 -A5000 -Bg -Wfaint \
    -EAF+gpeachpuff -ECM+gyellow -Sazure1 -O -K -X$x0 -Y$y0 >> $ps
gmt psbasemap -R -J \
    -D87.0/-27.0/90.0/7.0r -F+pthicker,red \
    -O -K >> $ps
gmt psxy -R -J -O -K -T -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx6.2/-3.3+o0.1i/0.1i+w2c -O >> $ps

# Convert to image file using GhostScript
gmt psconvert Bathymetry_NER.ps -A1.0c -E720 -Tj -Z
