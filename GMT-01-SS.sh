#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: South Sudan)
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert

exec bash

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
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R23.5/36.0/3/13 -Gss1_relief.nc
gmt grdcut GEBCO_2019.nc -R23.5/36.0/3/13 -Gss_relief.nc
gdalinfo -stats ss1_relief.nc
# actual_range={380,2929}

# Make color palette
# gmt makecpt -Cusgs.cpt -V -T380/1500 > pauline.cpt
# gmt makecpt -CDEM_print.cpt -V -T380/1500 > pauline.cpt
# gmt makecpt -Cafrikakarte-topo.cpt -V -T380/1500 > pauline.cpt
gmt makecpt -Cwiki-schwarzwald-cont.cpt -V -T380/1500 > pauline.cpt
# elevation etopo1 world elevation dem1 dem2 dem3 globe geo srtm turbo terra earth

#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R23.5/36.0/3/13 -JM6.5i -Dh -M -ESS > SSudan.txt
#####################################################################

ps=Topo_SS.ps
# Make background transparent image

gmt grdimage ss_relief.nc -Cpauline.cpt -R23.5/36.0/3/13 -JM6.5i -I+a15+ne0.75 -t40 -Xc -P -K > $ps

# Add isolines
gmt grdcontour ss1_relief.nc -R -J -C250 -A500+f7p,26,darkbrown -Wthinnest,darkbrown -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps
    
#####################################################################
# CLIPPING
# 1. Start: clip the map by mask to only include country

gmt psclip -R23.5/36.0/3/13 -JM6.5i SSudan.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage ss_relief.nc -Cpauline.cpt -R23.5/36.0/3/13 -JM6.5i -I+a15+ne0.75 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour ss1_relief.nc -R -J -C250 -A500+f7p,26,darkbrown -Wthinnest,darkbrown -O -K >> $ps
# Add coastlines, borders, rivers
gmt pscoast -R -J -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps
gmt pscoast -R -J -Ia/thinner,blue -Na -Sroyalblue1 -W2/thin,blue,0.1p -Df -O -K >> $ps

# 3: Undo the clipping
gmt psclip -C -O -K >> $ps
#####################################################################
    
# Add color legend
gmt psscale -Dg23.5/2.1+w16.5c/0.15i+h+o0.3/0i+ml+e -R -J -Cpauline.cpt \
    --FONT_LABEL=10p,0,black \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_TITLE=6p,0,black \
    -Bg200f10a100+l"Colormap: 'wiki-schwarzwald-cont' 380-1500, 150 segments [C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=WEsN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    --MAP_TITLE_OFFSET=0.7c \
    --MAP_TICK_PEN_PRIMARY=thinner,dimgray \
    --MAP_FRAME_WIDTH=0.1c \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --FONT_LABEL=8p,25,black \
    --FONT_TITLE=13p,0,black \
        -Bpxg4f1a2 -Bpyg4f2a2 -Bsxg2 -Bsyg2 \
    -B+t"Topographic map of South Sudan" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=10p,0,black \
    --FONT_ANNOT_PRIMARY=9p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx13.6c/-2.5c+c10+w400k+l"Mercator projection. Scale (km)"+f \
    -UBL/0p/-70p -O -K >> $ps

# Texts
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,19,black+jLB >> $ps << EOF
26.5 10.5 S U D A N
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f13p,19,black+jLB >> $ps << EOF
23.9 6.5 C E N T R A L
23.9 6.1 A F R I C A N
23.9 5.7 R E P U B L I C
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,19,black+jLB -Gwhite@70 >> $ps << EOF
24.2 4.1 C O N G O
24.4 3.7 (D.R.C.)
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f13p,19,black+jLB -Gwhite@70 >> $ps << EOF
31.3 3.2 U G A N D A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f13p,19,black+jLB -Gwhite@70 >> $ps << EOF
34.2 3.9 KENYA
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f13p,19,black+jLB -Gwhite@70 >> $ps << EOF
33.5 7.9 ETHIOPIA
EOF
# Cities -R23.5/36.0/3/13
# Geography
gmt pstext -R -J -N -O -K \
-F+f13p,23,blue+jLB >> $ps << EOF
32.50 9.7 Machar
32.50 9.3 Marshes
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,23,blue+jLB >> $ps << EOF
34.50 5.0 Lotagipi
34.50 4.6 Swamp
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,23,darkgreen+jLB >> $ps << EOF
33.00 7.4 Boma
32.70 7.0 National
33.00 6.6 Park
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,23,darkgreen+jLB -Gwhite@70 >> $ps << EOF
28.10 6.5 Southern
28.10 6.1 National
28.10 5.8 Park
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,23,darkred+jLB+a-45 -Gwhite@70 >> $ps << EOF
25.80 7.6 IRONSTONE PLATEAU
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,23,darkgreen+jLB+a-40 -Gwhite@70 >> $ps << EOF
31.80 4.4 Imatong
32.00 4.0 Mts
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,23,blue1+jLB+a80 >> $ps << EOF
31.40 4.4 Al-Jabal
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,23,blue1+jLB+a80 >> $ps << EOF
30.60 8.2 Al-Zaraf
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,23,blue1+jLB+a25 >> $ps << EOF
29.40 9.15 Al-Ghazal
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,23,blue1+jLB+a-25 >> $ps << EOF
28.20 9.6 Bahr al-Arab
EOF

# insert map
# Countries codes: ISO 3166-1 alpha-2. Continent codes AF (Africa), AN (Antarctica), AS (Asia), EU (Europe), OC (Oceania), NA (North America), or SA (South America). -EEU+ggrey
gmt psbasemap -R -J -O -K -DjTL+w3.0c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thin,grey -Rg -JG28.0/8.0N/$w -Da -Glightgoldenrod1 -A5000 -Bga -Wfaint -ESS+gred -Sdodgerblue -O -K -X$x0 -Y$y0 >> $ps
#gmt pscoast -Rg -JG12/5N/$w -Da -Gbrown -A5000 -Bg -Wfaint -ECM+gbisque -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx7.0/-3.0+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y7.6c -N -O \
    -F+f10p,0,black+jLB >> $ps << EOF
3.0 10.4 Digital elevation data: SRTM/GEBCO, 15 arc sec resolution grid
EOF

# Convert to image file using GhostScript
gmt psconvert Topo_SS.ps -A1.5c -E720 -Tj -Z
