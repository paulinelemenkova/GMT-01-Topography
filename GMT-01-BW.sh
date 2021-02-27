#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: Botswana)
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
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R19.5/29.5/-27/-17.5 -Gbw_relief.nc
#gmt grdcut GEBCO_2019.nc -R19.5/29.5/-27/-17.5 -Gbw_relief.nc
gdalinfo -stats bw_relief.nc
# Minimum=494.000, Maximum=1940.000, Mean=1103.457, StdDev=177.299

#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R19.5/29.5/-27/-17.5 -JM6.5i -Dh -M -EBW > Botswana.txt
#gmt pscoast -Dh -M -ELB > Malawi.txt
#####################################################################

# Make color palette
#gmt makecpt -Cafrikakarte-topo -V -T443/5110 > pauline.cpt
gmt makecpt -Ceurope_2 -V -T494/1940 > pauline.cpt
# elevation etopo1 world elevation dem1 dem2 dem3 globe geo srtm turbo terra earth relief costa-rica

ps=Topo_BW.ps
# Make background transparent image
gmt grdimage bw_relief.nc -Cpauline.cpt -R19.5/29.5/-27/-17.5 -JM6.5i -I+a15+ne0.75 -t50 -Xc -P -K > $ps
    
# Add isolines
gmt grdcontour bw_relief.nc -R -J -C100 -A200+f7p,26,darkbrown -Wthinner,darkbrown -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,red -W0.1p -Df -O -K >> $ps
    
#####################################################################
# CLIPPING
# 1. Start: clip the map by mask to only include country
#gmt psclip -JM -R Malawi.txt -O -K >> $ps

gmt psclip -R19.5/29.5/-27/-17.5 -JM6.5i Botswana.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage bw_relief.nc -Cpauline.cpt -R19.5/29.5/-27/-17.5 -JM6.5i -I+a15+ne0.75 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour bw_relief.nc -R -J -C100 -A100+f7p,26,darkbrown -Wthinner,darkbrown -O -K >> $ps
# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps
#gmt pscoast -R -J \
    -Ia/thinner,blue -Na -W0.1p -Df -O -K >> $ps

# 3: Undo the clipping
gmt psclip -C -O -K >> $ps
#####################################################################
    
# Add color legend
gmt psscale -Dg19.3/-27.7+w16.5c/0.15i+h+o0.3/0i+ml+e -R -J -Cpauline.cpt \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_TITLE=6p,0,black \
    -Bg200f10a100+l"Colormap: 'europe 2' scheme for hypsometry elevation of land elevations by ESRI [-T494/1940, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=WEsN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    -Bpxg1f0.5a1 -Bpyg1f0.5a1 -Bsxg1 -Bsyg1 \
    --MAP_TITLE_OFFSET=0.8c \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --FONT_LABEL=8p,25,black \
    --FONT_TITLE=16p,19,black \
    -B+t"Topographic map of Botswana" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx14.5c/-2.5c+c10+w200k+l"Mercator projection. Scale (km)"+f \
    -UBL/0p/-70p -O -K >> $ps

# Texts
# Cities
gmt pstext -R -J -N -O -K \
-F+f13p,0,black+jLB -Gwhite@50 >> $ps << EOF
25.96 -24.60 Gaborone
EOF
gmt psxy -R -J -Ss -W0.5p -Gcyan -O -K << EOF >> $ps
25.91 -24.65 0.30c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@50 >> $ps << EOF
27.56 -21.12 Francistown
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
27.51 -21.17 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@50 >> $ps << EOF
25.72 -25.16 Lobatse
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
25.67 -25.21 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@50 >> $ps << EOF
26.27 -20.51 Sowa
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
26.22 -20.56 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@50 >> $ps << EOF
25.42 -21.27 Orapa
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
25.37 -21.33 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@50 >> $ps << EOF
24.65 -24.67 Jwaneng
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
24.60 -24.72 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@50 >> $ps << EOF
27.89 -21.92 Selebi-Phikwe
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
27.84 -21.98 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@50 >> $ps << EOF
24.45 -20.99 Rakops
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
24.41 -21.04 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@50 >> $ps << EOF
22.77 -20.47 Sehithwa
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
22.72 -20.47 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@50 >> $ps << EOF
26.23 -20.16 Nata
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
26.18 -20.21 0.20c
EOF
# countries
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,25,black+jLB -Gwhite@60 >> $ps << EOF
19.7 -20.0 N A M I B I A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,25,black+jLB -Gwhite@60 >> $ps << EOF
20.5 -17.7 A N G O L A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,25,black+jLB -Gwhite@60 >> $ps << EOF
25.5 -17.7 Z A M B I A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,25,black+jLB -Gwhite@60 >> $ps << EOF
23.5 -26.6 S O U T H   A F R I C A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,25,black+jLB -Gwhite@60 >> $ps << EOF
27.1 -19.5 Z I M B A B W E
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,19,black+jLB -Gwhite@80 >> $ps << EOF
22.5 -22.0 B  O  T  S  W  A  N  A
EOF


# insert map
# Countries codes: ISO 3166-1 alpha-2. Continent codes AF (Africa), AN (Antarctica), AS (Asia), EU (Europe), OC (Oceania), NA (North America), or SA (South America). -EEU+ggrey
gmt psbasemap -R -J -O -K -DjBR+w3.4c+o-0.2c/-0.2c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thinnest,white -Rg -JG28.0/-2.0S/$w -Da -Glightgoldenrod1 -A5000 -Bga -Wfaint -EBW+gred -Sdodgerblue -O -K -X$x0 -Y$y0 >> $ps
#gmt pscoast -Rg -JG12/5N/$w -Da -Gbrown -A5000 -Bg -Wfaint -ECM+gbisque -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx7.3/-2.8+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y11.8c -N -O \
    -F+f10p,0,black+jLB >> $ps << EOF
2.0 9.0 Digital elevation data: GEBCO/SRTM, 15 arc sec (ca. 450 m) resolution grid
EOF

# Convert to image file using GhostScript
gmt psconvert Topo_BW.ps -A0.5c -E720 -Tj -Z
