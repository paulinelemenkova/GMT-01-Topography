#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: Belgium)
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert
# http://soliton.vm.bytemark.co.uk/pub/cpt-city/njgs/index.html

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

# Extract a subset of ETOPO1m for the study area
#gmt grdcut ETOPO1_Ice_g_gmt4.grd -R2.5/6.5/49.5/51.7 -Gbe_relief.nc
gmt grdcut GEBCO_2019.nc -R2.5/6.5/49.5/51.7 -Gbe_relief.nc
gdalinfo -stats be_relief.nc
# Minimum=-164.000, Maximum=680.000, Mean=127.359, StdDev=141.386

#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R2.5/6.5/49.5/51.7 -JM5.0i -Dh -M -EBE > Belgium.txt
#gmt pscoast -Dh -M -ELB > Malawi.txt
#####################################################################

# Make color palette
gmt makecpt -Cgeo -V -T-164/680 > pauline.cpt
# elevation etopo1 world elevation dem1 dem2 dem3 globe geo srtm turbo terra earth relief costa-rica

ps=Topo_BE.ps
# Make background transparent image
gmt grdimage be_relief.nc -Cpauline.cpt -R2.5/6.5/49.5/51.7 -JM5.0i -I+a15+ne0.75 -t50 -Xc -P -K > $ps
    
# Add isolines
gmt grdcontour be_relief.nc -R -J -C1000 -A1000+f7p,26,darkbrown -Wthinner,darkbrown -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,red -W0.1p -Df -O -K >> $ps
    
#####################################################################
# CLIPPING
# 1. Start: clip the map by mask to only include country

gmt psclip -R2.5/6.5/49.5/51.7 -JM5.0i Belgium.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage be_relief.nc -Cpauline.cpt -R2.5/6.5/49.5/51.7 -JM5.0i -I+a15+ne0.75 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour be_relief.nc -R -J -C250 -Wthinnest,darkbrown -O -K >> $ps
# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps

# 3: Undo the clipping
gmt psclip -C -O -K >> $ps
#####################################################################
    
# Add color legend
gmt psscale -Dg2.5/49.25+w12.5c/0.15i+h+o0.3/0i+ml+e -R -J -Cpauline.cpt \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_TITLE=6p,0,black \
    -Bg100f10a100+l"Colormap: 'geo' scheme for topography. [R=-164/680, H, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=WEsN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    -Bpxg1f1a0.5 -Bpyg0.5f0.5a0.5 -Bsxg1 -Bsyg0.5 \
    --MAP_TITLE_OFFSET=0.8c \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --FONT_LABEL=8p,25,black \
    --FONT_TITLE=14p,25,black \
    -B+t"Study area: location of Uccle seismic station, Belgium" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx11.0c/-2.3c+c10+w100k+l"Mercator projection. Scale (km)"+f \
    -UBL/0p/-70p -O -K >> $ps

# Texts
gmt pstext -R -J -N -O -K \
-F+jTL+f17p,25,white+jLB >> $ps << EOF
4.25 50.54 B E L G I U M
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,0,black+jLB -Gwhite@60 >> $ps << EOF
4.40 50.84 Brussels
EOF
gmt psxy -R -J -Ss -W0.5p -Gred -O -K << EOF >> $ps
4.35 50.84 0.40c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,0,black+jLB -Gwhite@50 >> $ps << EOF
4.4 50.75 Uccle
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
4.33 50.8 0.30c
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,0,BROWN4+jLB >> $ps << EOF
2.85 50.19 F  R  A  N  C  E
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,0,BROWN4+jLB >> $ps << EOF
4.45 51.55 N E T H E R L A N D S
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,0,BROWN4+jLB+a-270 >> $ps << EOF
6.38 50.6 G E R M A N Y
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,0,BROWN4+jLB -Gwhite@60 >> $ps << EOF
5.83 49.73 LUXEMBOURG
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,2,navyblue+jLB >> $ps << EOF
2.6 51.5 NORTH SEA
EOF

# insert map
# Countries codes: ISO 3166-1 alpha-2. Continent codes AF (Africa), AN (Antarctica), AS (Asia), EU (Europe), OC (Oceania), NA (North America), or SA (South America). -EEU+ggrey
gmt psbasemap -R -J -O -K -DjBL+w3.0c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thinnest,grey -Rg -JG16/62/$w -Da -Glightgoldenrod1 -A5000 -Bga -Wfaint -EBE+gred -Sdodgerblue -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx5.5/-3.1+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y5.7c -N -O \
    -F+f10p,0,black+jLB >> $ps << EOF
0.0 9.0 Digital elevation data: GEBCO/SRTM, 15 arc sec resolution grid
EOF

# Convert to image file using GhostScript
gmt psconvert Topo_BE.ps -A0.5c -E720 -Tj -Z
