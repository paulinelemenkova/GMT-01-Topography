#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: Sudan)
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
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R14/28/2/11.5 -Gcf1_relief.nc
gmt grdcut GEBCO_2019.nc -R14/28/2/11.5 -Gcf_relief.nc
gdalinfo -stats cf_relief.nc
# actual_range={212.1953125,1819.83984375}

# Make color palette
gmt makecpt -Cearth -V -T212/1820 > pauline.cpt
# elevation etopo1 world elevation dem1 dem2 dem3 globe geo srtm turbo terra earth

#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R14/28/2/11.5 -JM6.5i -Dh -M -ECF > CAR.txt
#####################################################################

ps=Topo_CF.ps
# Make background transparent image

gmt grdimage cf1_relief.nc -Cpauline.cpt -R14/28/2/11.5 -JM6.5i -I+a15+ne0.75 -t40 -Xc -P -K > $ps

# Add isolines
gmt grdcontour cf1_relief.nc -R -J -C250 -A500+f7p,26,darkbrown -Wthinnest,darkbrown -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps
    
#####################################################################
# CLIPPING
# 1. Start: clip the map by mask to only include country

gmt psclip -R14/28/2/11.5 -JM6.5i CAR.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage cf1_relief.nc -Cpauline.cpt -R14/28/2/11.5 -JM6.5i -I+a15+ne0.75 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour cf1_relief.nc -R -J -C250 -A500+f7p,26,darkbrown -Wthinnest,darkbrown -O -K >> $ps
# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps
#gmt pscoast -R -J \
    -Ia/thinner,blue -Na -W0.1p -Df -O -K >> $ps

# 3: Undo the clipping
gmt psclip -C -O -K >> $ps
#####################################################################
    
# Add color legend
gmt psscale -Dg14/1+w16.0c/0.15i+h+o0.3/0i+ml+e -R -J -Cpauline.cpt \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_TITLE=6p,0,black \
    -Bg200f10a200+l"Colormap: 'geo' Colors for global topography relief [R=-2756/3042, H, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=WEsN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    --MAP_TITLE_OFFSET=0.7c \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --FONT_LABEL=8p,25,black \
    --FONT_TITLE=13p,0,black \
        -Bpxg4f1a2 -Bpyg4f2a2 -Bsxg2 -Bsyg2 \
    -B+t"Topographic map of Central African Republic" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=9p,0,black \
    --FONT_ANNOT_PRIMARY=9p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx14.5c/-2.4c+c10+w300k+l"Mercator projection. Scale (km)"+f \
    -UBL/0p/-70p -O -K >> $ps

# Texts
# Cities -R14/28/2/11.5
gmt pstext -R -J -N -O -K \
-F+f10p,21,black+jLB -Gwhite@50 >> $ps << EOF
15.90 4.36 Berbérati
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
15.79 4.26 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,21,black+jLB -Gwhite@50 >> $ps << EOF
15.96 5.03 Carnot
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
15.86 4.93 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,21,black+jLB -Gwhite@50 >> $ps << EOF
20.77 5.87 Bambari
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
20.67 5.77 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,21,black+jLB -Gwhite@50 >> $ps << EOF
15.7 6.05 Bouar
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
15.6 5.95 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,21,black+jLB -Gwhite@50 >> $ps << EOF
17.15 6.15 Bossangoa
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
17.45 6.48 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,21,black+jLB -Gwhite@50 >> $ps << EOF
22.09 6.64 Bria
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
21.99 6.54 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,21,black+jLB -Gwhite@50 >> $ps << EOF
22.62 4.90 Bangassou
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
22.82 4.74 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,21,black+jLB -Gwhite@50 >> $ps << EOF
18.3 6.73 Kaga-Bandoro
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
19.18 7.00 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,21,black+jLB -Gwhite@50 >> $ps << EOF
17.50 3.98 Mbaïki
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
18 3.88 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f14p,22,black+jLB -Gwhite@50 >> $ps << EOF
17.65 4.58 Bangui
EOF
gmt psxy -R -J -Sa -W0.5p -Gred -O -K << EOF >> $ps
18.56 4.37 0.35c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,floralwhite+jLB >> $ps << EOF
15.1 6.60 Karre
15.2 6.30 Mts.
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,21,floralwhite+jLB+a15 -Glightbrown@70 >> $ps << EOF
21.8 8.05 Bongos Massif
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,21,floralwhite+jLB >> $ps << EOF
23.7 8.05 Tondou
23.75 7.8 Massif
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,21,khaki+jLB >> $ps << EOF
24.7 7.00 Zemongo
24.7 6.75 Faunal
24.7 6.50 Reserve
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,21,darkgreen+jLB -Gwhite@60 >> $ps << EOF
21.7 9.75 Ouandjia-Vakaga
21.7 9.50 Faunal Reserve
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,23,blue2+jLB+a-41 -Gwhite@60 >> $ps << EOF
20.0 8.6 Bangoran
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,23,blue2+jLB+a-43 -Gwhite@60 >> $ps << EOF
19.58 7.8 Bamingui
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,23,blue2+jLB+a50 -Gwhite@80 >> $ps << EOF
17.60 6.6 Ouham
EOF
# insert map
# Countries codes: ISO 3166-1 alpha-2. Continent codes AF (Africa), AN (Antarctica), AS (Asia), EU (Europe), OC (Oceania), NA (North America), or SA (South America). -EEU+ggrey
gmt psbasemap -R -J -O -K -DjTL+w3.5c+o-0.2c/-0.2c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thin,grey -Rg -JG28.0/8.0N/$w -Da -Glightgoldenrod1 -A5000 -Bga -Wfaint -ECF+gred -Sdodgerblue -O -K -X$x0 -Y$y0 >> $ps
#gmt pscoast -Rg -JG12/5N/$w -Da -Gbrown -A5000 -Bg -Wfaint -ECM+gbisque -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx7.0/-3.1+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y5.0c -N -O \
    -F+f10p,0,black+jLB >> $ps << EOF
3.0 10.4 Digital elevation data: SRTM/GEBCO, 15 arc sec resolution grid
EOF

# Convert to image file using GhostScript
gmt psconvert Topo_CF.ps -A0.5c -E720 -Tj -Z
