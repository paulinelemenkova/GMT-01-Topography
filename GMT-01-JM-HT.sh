#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO dataset (here: Aegean Sea, Hellenic Trench)
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
# Step-3. Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults

grdcut GEBCO_2019.nc -R19/37/30.5/41.5 -Ght_relief.nc
#grdcut ETOPO1_Ice_g_gmt4.grd -R19/37/30.5/41.5 -Ght_relief.nc

gdalinfo ht_relief.nc -stats
#  Minimum=-5119.000, Maximum=3505.000
# Make color palette
# makecpt --help
gmt makecpt -Cgeo.cpt -V -T-5119/3505 > myocean.cpt

# Generate a file
ps=Bathymetry_HT.ps
# Make raster image
gmt grdimage ht_relief.nc -Cmyocean.cpt -R19/37/30.5/41.5 -JM6i -P -I+a15+ne0.75 -Xc -K > $ps

# Add grid
gmt psbasemap -R -J \
    -Bpx4f1a2 -Bpyg4f1a2 -Bsxg2 -Bsyg2 \
    --MAP_TITLE_OFFSET=0.8c \
    -B+t"Topographic map of the Aegean Sea region" -O -K >> $ps
    
# Add shorelines
gmt grdcontour ht_relief.nc -R -J -C1000 -W0.1p -O -K >> $ps
    
# Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=8p,Palatino-Roman,black \
    --MAP_TITLE_OFFSET=0.3c \
    -Tdx13.8c/1.0c+w0.2i+f2+l+o0.1c \
    -Lx13.0c/-1.3c+c50+w400k+l"Mercator projection. Scale: km"+f \
    -UBL/-5p/-40p -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P \
    -Ia/thinnest,blue -Na -N1/thinner,red -W0.1p -Df -O -K >> $ps

# Add legend
gmt psscale -Dg16.0/30.5+w11.4c/0.4c+v+o0.3/0i+ml -R -J -Cmyocean.cpt \
    --FONT_LABEL=6p,Helvetica,dimgray \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,black \
    -Baf+l"Color scale: geo global bathymetry/topography relief [R=-5119/3505, H=0, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps
    
gmt psxy -R -J trench.gmt -Sf1.5c/0.2c+l+t -Wthick,purple -Gpurple -O -K >> $ps
gmt psxy -R -J volcanoes.gmt -St0.17c -Gred -Wthinnest -O -K >> $ps
gmt psxy -R -J PB2002_boundaries.gmt -Sf1.5c/0.2c+l+t -Wthick,yellow -Gpurple -O -K >> $ps
gmt psxy -R -J TP_Eurasian.txt -L -Wthickest,red -O -K >> $ps
gmt psxy -R -J TP_African.txt -L -Wthickest,red -O -K >> $ps
gmt psxy -R -J TP_Arabian.txt -L -Wthickest,red -O -K >> $ps
gmt psxy -R -J SC_hellas.txt -Wthinner,purple -O -K >> $ps
gmt psxy -R -J SC_italia.txt -Wthinner,purple -O -K >> $ps

# Add GMT logo
gmt logo -Dx6.2/-2.0+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y5.7c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
2.8 9.7 GEBCO global terrain model, 15 arc sec resolution grid
EOF

# Convert to image file using GhostScript
gmt psconvert Bathymetry_HT.ps -A0.5c -E720 -Tj -Z
