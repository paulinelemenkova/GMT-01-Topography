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
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R2/15/3/14 -Gng1_relief.nc
gmt grdcut GEBCO_2019.nc -R2/15/3/14 -Gng_relief.nc
gdalinfo -stats ng1_relief.nc
# Minimum=-4373.000, Maximum=3703.000, Mean=157.600, StdDev=902.766

# Make color palette
gmt makecpt -Cgeo -V -T-4373/3703 > pauline.cpt
# elevation etopo1 world elevation dem1 dem2 dem3 globe geo srtm turbo terra earth

#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R2/15/3/14 -JM6.5i -Dh -M -ENG > NG.txt
#####################################################################

ps=Topo_NG.ps
# Make background transparent image

gmt grdimage ng1_relief.nc -Cpauline.cpt -R2/15/3/14 -JM6.5i -I+a15+ne0.75 -t40 -Xc -P -K > $ps

# Add isolines
gmt grdcontour ng1_relief.nc -R -J -C250 -A500+f7p,26,darkbrown -Wthinnest,darkbrown -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps
    
#####################################################################
# CLIPPING
# 1. Start: clip the map by mask to only include country

gmt psclip -R2/15/3/14 -JM6.5i NG.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage ng1_relief.nc -Cpauline.cpt -R2/15/3/14 -JM6.5i -I+a15+ne0.75 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour ng1_relief.nc -R -J -C250 -A500+f7p,26,darkbrown -Wthinnest,darkbrown -O -K >> $ps
# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps

# 3: Undo the clipping
gmt psclip -C -O -K >> $ps
#####################################################################
    
# Add color legend
gmt psscale -Dg2/2+w16.0c/0.15i+h+o0.3/0i+ml+e -R -J -Cpauline.cpt \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_TITLE=6p,0,black \
    -Bg500f100a500+l"Colormap: 'geo' Colors for global topography relief [R=-4373/3703, H, C=RGB]" \
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
    -B+t"Topographic map of Nigeria" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=9p,0,black \
    --FONT_ANNOT_PRIMARY=9p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx14.5c/-2.4c+c10+w300k+l"Mercator projection. Scale (km)"+f \
    -UBL/0p/-70p -O -K >> $ps

# Texts
# countries
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,19,black+jLB -Gwhite@80 >> $ps << EOF
8.2 13.6 N I G E R
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,19,black+jLB -Gwhite@70 >> $ps << EOF
10.1 5.8 C A M E R O O N
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,19,black+jLB -Gwhite@80 >> $ps << EOF
13.9 13.5 CHAD
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f13p,19,black+jLB -Gwhite@80 >> $ps << EOF
2.1 10.6 B E N I N
EOF
# water
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,26,white+jLB >> $ps << EOF
2.3 3.3 A t l a n t i c  O c e a n
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,26,white+jLB >> $ps << EOF
3.5 3.7 G u l f  o f  G u i n e a
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,26,white+jLB >> $ps << EOF
2.5 5.2 Bight of
2.5 4.9 Benin
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,26,blue1+jLB -Gwhite@70 >> $ps << EOF
6.8 3.6 Bight of
6.8 3.3 Biafra
EOF
#
# Texts
# Cities for area -R2/15/3/14
gmt pstext -R -J -N -O -K \
-F+f12p,21,black+jLB -Gwhite@70 >> $ps << EOF
4.70 8.50 Ilorin
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
4.55 8.50 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,21,black+jLB -Gwhite@70 >> $ps << EOF
5.32 7.45 Ado Ekiti
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
5.22 7.62 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f14p,21,lemonchiffon+jLB >> $ps << EOF
3.15 6.65 Lagos
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
3.38 6.45 0.30c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,21,black+jLB -Gwhite@70 >> $ps << EOF
4.70 7.90 Osogbo
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
4.57 7.76 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,21,black+jLB >> $ps << EOF
12.10 11.50 Maiduguri
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
13.15 11.83 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,21,black+jLB >> $ps << EOF
8.62 12.10 Kano
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
8.52 12.00 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,21,lemonchiffon+jLB >> $ps << EOF
7.05 10.67 Kaduna
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
7.43 10.52 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,21,lemonchiffon+jLB >> $ps << EOF
8.08 5.03 Uyo
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
7.92 5.03 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,21,lemonchiffon+jLB >> $ps << EOF
5.72 6.50 Benin City
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
5.62 6.33 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,21,lemonchiffon+jLB >> $ps << EOF
5.80 4.45 Port Harcourt
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
7.03 4.82 0.30c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,21,lemonchiffon+jLB >> $ps << EOF
7.63 6.45 Enugu
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
7.51 6.45 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,21,lemonchiffon+jLB >> $ps << EOF
2.90 7.30 Abeokuta
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
3.35 7.16 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f14p,22,black+jLB -Gwhite@70 >> $ps << EOF
6.90 9.20 ABUJA
EOF
gmt psxy -R -J -Sa -W0.5p -Gred -O -K << EOF >> $ps
7.48 9.06 0.35c
EOF
# Study area
# Rotated rectangle. kwargs: coords, direction degrees, x and y-dimension
gmt psxy -R -J -Sj1c -W1.5p,red -O -K << EOF >> $ps
5.80 5.80 -15 1.5 1.5
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,21,lightgreen+jLB >> $ps << EOF
5.50 5.90 Study
5.50 5.60 Area
EOF
# insert map
# Countries codes: ISO 3166-1 alpha-2. Continent codes AF (Africa), AN (Antarctica), AS (Asia), EU (Europe), OC (Oceania), NA (North America), or SA (South America). -EEU+ggrey
gmt psbasemap -R -J -O -K -DjBR+w3.5c+o-0.2c/-0.2c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thin,grey -Rg -JG10/8N/$w -Da -Glightgoldenrod1 -A5000 -Bga -Wfaint -ENG+gred -Sdodgerblue -O -K -X$x0 -Y$y0 >> $ps
#gmt pscoast -Rg -JG12/5N/$w -Da -Gbrown -A5000 -Bg -Wfaint -ECM+gbisque -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx7.0/-3.0+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y8.0c -N -O \
    -F+f10p,0,black+jLB >> $ps << EOF
3.0 10.4 Digital elevation data: SRTM/GEBCO, 15 arc sec resolution grid
EOF

# Convert to image file using GhostScript
gmt psconvert Topo_NG.ps -A0.5c -E720 -Tj -Z
