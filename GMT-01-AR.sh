#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO dataset (here: Argentina)
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

#gmt grdcut GEBCO_2019.nc -R285/306/-56/-20 -Gar_relief.nc
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R285/306/-56/-20 -Gar_relief.nc

gdalinfo ar_relief.nc -stats
# Minimum=-6324.000, Maximum=6560.000, Mean=-8.461, StdDev=1666.822

#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R285/306/-56/-20 -Dh -M -EAR > ar.txt
#####################################################################

# Make color palette
# makecpt --help
gmt makecpt -Cgeo.cpt -V -T-6324/6560 > pauline.cpt

# Generate a file
ps=Topography_AR.ps
# Make background transparent image
#gmt grdimage ar_relief.nc -Cpauline.cpt -R285/306/-56/-20 -JT295/4.5i -P -I+a15+ne0.75 -t50 -Xc -K > $ps
gmt grdimage ar_relief.nc -Cpauline.cpt -R285/306/-56/-20 -JT295/4.5i -P -I+a15+ne0.75 -t50 -Xc -K > $ps
    
# Add isolines
gmt grdcontour ar_relief.nc -R -J -C1000 -W0.1p -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P \
    -Ia/thinner,blue -Na -N1/thickest,red -W0.1p -Df -O -K >> $ps
    
#####################################################################
# CLIPPING
# 1. Start: clip the map by mask to only include country

gmt psclip -R285/306/-56/-20 -JT295/4.5i ar.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage ar_relief.nc -Cpauline.cpt -R285/306/-56/-20 -JT295/4.5i -I+a15+ne0.75 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour ar_relief.nc -R -J -C1000 -Wthinnest,darkbrown -O -K >> $ps
# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps

# 3: Undo the clipping
gmt psclip -C -O -K >> $ps
#####################################################################

# Add color barlegend
gmt psscale -Dg284/-58.0+w7.0c/0.4c+h+o0.0/0i+ml -R -J -Cpauline.cpt \
    --FONT_LABEL=8p,Helvetica,black \
    --MAP_LABEL_OFFSET=0.1c \
    --FONT_ANNOT_PRIMARY=6p,0,black \
    -Bg1000f100a2000+l"Color scale 'geo': global bathymetry/topography relief [R=-6857/3206, H=0, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=WEsN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    -Bpx4f2a4 -Bpyg4f2a4 -Bsxg4 -Bsyg2 \
    --MAP_TITLE_OFFSET=1.0c \
    --FONT_TITLE=14p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=7p,Helvetica,black \
    -B+t"Topographic map of Argentina" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=10p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --MAP_LABEL_OFFSET=0.1c \
    -Lx8.6c/-2.2c+c50+w600k+l"Transverse Mercator Prj. Scale: km"+f \
    -UBL/30p/-60p -O -K >> $ps
    
# Texts

# insert map
# Countries codes: ISO 3166-1 alpha-2. Continent codes AF (Africa), AN (Antarctica), AS (Asia), EU (Europe), OC (Oceania), NA (North America), or SA (South America). -EEU+ggrey
gmt psbasemap -R -J -O -K -DjTR+w3.0c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thin,grey -Rg -JG298/40S/$w -Da -Gbrown -A5000 -Bg -Wfaint -ESA+gpeachpuff -EAR+gyellow -Slightskyblue1 -O -K -X$x0 -Y$y0 >> $ps
#gmt pscoast -Rg -JG12/5N/$w -Da -Gbrown -A5000 -Bg -Wfaint -ECM+gbisque -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx4.3/-3.6+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.0c -Y12.7c -N -O \
    -F+f12p,Helvetica,black+jLB >> $ps << EOF
0.0 13.6 SRTM/GEBCO 15 arc sec resolution global terrain model grid
EOF

# Convert to image file using GhostScript
gmt psconvert Topography_AR.ps -A1.0c -E720 -Tj -Z
