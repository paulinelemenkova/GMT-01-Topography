#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: Benin)
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
    FONT_ANNOT_PRIMARY=7p,0,dimgray \
    FONT_LABEL=7p,0,dimgray \
# Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults

exec bash

# Extract a subset of ETOPO1m for the study area
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R110/160/-45/-10 -Gau1_relief.nc
gmt grdcut GEBCO_2023.nc -R110/160/-45/-10 -Gau_relief.nc
gmt grdinfo -M au_relief.nc
# gdalinfo -stats au_relief.nc

# Make color palette
gmt makecpt -Cgeo -V -T-7329/2735 > pauline.cpt
# elevation etopo1 world elevation dem1 dem2 dem3 globe geo srtm turbo terra earth

#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R110/160/-45/-10 -JM6.5i -Dh -M -EAU > Australia.txt
#####################################################################

ps=Topo_AU.ps
# Make background transparent image
gmt grdimage au1_relief.nc -Cpauline.cpt -R110/160/-45/-10 -JM6.5i -I+a15+ne0.75 -t40 -Xc -K > $ps
    
# Add isolines
gmt grdcontour au1_relief.nc -R -J -C1000 -A1000+f6p,26,darkbrown -Wthinnest,darkbrown -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thick,dimgray -W0.1p -Df -O -K >> $ps
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps
    
#####################################################################
# CLIPPING
# 1. Start: clip the map by mask to only include country
gmt psclip -R110/160/-45/-10 -JM6.5i Australia.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage au1_relief.nc -Cpauline.cpt -R110/160/-45/-10 -JM6.5i -I+a15+ne0.75 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour au1_relief.nc -R -J -C1000 -Wthinnest,darkbrown -O -K >> $ps
# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps
# Add lakes
gmt pscoast -R -J -Ia/thinner,blue -Na -Sroyalblue1 -W2/thin,blue,0.1p -Df -O -K >> $ps

# 3: Undo the clipping
gmt psclip -C -O -K >> $ps
#####################################################################
    
# Add color legend -R110/160/-45/-10
gmt psscale -Dg102/-42+w12.0c/0.15i+v+o0.3/0i+ml+e -R -J -Cpauline.cpt \
    --FONT_LABEL=10p,0,black \
    --FONT_ANNOT_PRIMARY=10p,0,black \
    --FONT_TITLE=10p,0,black \
    -Bg500f50a500+l"Colormap: 'geo' Colors for global bathymetry/topography relief [R=-7329/2735, H, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=wESN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    --MAP_TITLE_OFFSET=0.7c \
    --FONT_ANNOT_PRIMARY=9p,0,black \
    --FONT_LABEL=10p,25,black \
    --FONT_TITLE=12p,0,black \
        -Bpxg2f2a4 -Bpyg2f2a4 -Bsxg4 -Bsyg4 \
    -B+t"Topographic map of Australia with location of the study area" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=11p,0,black \
    --FONT_ANNOT_PRIMARY=10p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx14.0c/-1.7c+c10+w1000k+l"Mercator projection. Scale (km)"+f \
    -UBL/0p/-40p -O -K >> $ps
    
# Texts

# Study area
# Rotated rectangle. kwargs: -Sjdirection/width/height, coords
# gmt psxy -R -J -Sj-13/2.8/2.8 -W1.5p,cyan -O -K << EOF >> $ps
# 12.52 43.18
# EOF
# Study area
# Rotated rectangle. kwargs: -Sjdirection/width/height, coords
# gmt psxy -R -J -Sj0/0.5/0.5 -W1.5p,yellow -O -K << EOF >> $ps
# 11.78 43.87
# EOF
# insert map
# Countries codes: ISO 3166-1 alpha-2. Continent codes AF (Africa), AN (Antarctica), AS (Asia), EU (Europe), OC (Oceania), NA (North America), or SA (South America). -EEU+ggrey -R110/160/-45/-10
gmt psbasemap -R -J -O -K -DjTR+w3.5c+o-0.2c/-0.2c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thin,grey -Rg -JG140/25.0S/$w -Da -Glightgoldenrod1 -A5000 -Bga -Wfaint -EAU+gred -Sdodgerblue -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx6.5/-2.1+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
# gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y13.2c -N -O \
  #  -F+f12p,0,black+jLB >> $ps << EOF
# 0.2 10.0 Location of Landsat OLI/TIRS 8-9 satellite images: rotated cyan-colored  # square
# EOF
# Convert to image file using GhostScript
gmt psconvert Topo_AU.ps -A1.0c -E720 -Tj -Z
