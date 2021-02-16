#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: Rwanda)
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

# Extract a subset of ETOPO1m for the study area
#gmt grdcut ETOPO1_Ice_g_gmt4.grd -R28.5/31/-3/-1 -Grw_relief1.nc
gmt grdcut GEBCO_2019.nc -R28.5/31/-3/-1 -Grw_relief.nc
gdalinfo -stats rw_relief.nc
# Minimum=806.098, Maximum=4359.250

# Make color palette
gmt makecpt -Cturbo.cpt -V -T806/4360 > pauline.cpt
# elevation etopo1 world elevation dem1 dem2 dem3 globe geo srtm turbo terra earth relief

#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R28.5/31/-3/-1 -JM6.5i -Dh -M -ERW > Rwanda.txt
#gmt pscoast -Dh -M -ELB > Malawi.txt
#####################################################################

ps=Topo_RW.ps
# Make background transparent image
gmt grdimage rw_relief.nc -Cpauline.cpt -R28.5/31/-3/-1 -JM6.5i -I+a15+ne0.75 -t40 -Xc -P -K > $ps
    
# Add isolines
gmt grdcontour gh_relief1.nc -R -J -C1000 -A1000+f7p,26,darkbrown -Wthinner,darkbrown -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thick,dimgray -W0.1p -Df -O -K >> $ps
    
#####################################################################
# CLIPPING
# 1. Start: clip the map by mask to only include country
#gmt psclip -JM -R Malawi.txt -O -K >> $ps

gmt psclip -R28.5/31/-3/-1 -JM6.5i Rwanda.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage rw_relief.nc -Cpauline.cpt -R28.5/31/-3/-1 -JM6.5i -I+a15+ne0.75 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour rw_relief.nc -R -J -C250 -Wthinnest,darkbrown -O -K >> $ps
# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps
#gmt pscoast -R -J \
    -Ia/thinner,blue -Na -W0.1p -Df -O -K >> $ps

# 3: Undo the clipping
gmt psclip -C -O -K >> $ps
#####################################################################
    
# Add color legend
gmt psscale -Dg28.5/-3.2+w16.5c/0.15i+h+o0.3/0i+ml+e -R -J -Cpauline.cpt \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_TITLE=6p,0,black \
    -Bg500f50a500+l"Colormap: 'geo' Colors for global bathymetry/topography relief [R=-4696/915, H, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=WEsN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    -Bpxg1f0.5a0.25 -Bpyg1f0.5a0.25 -Bsxg1 -Bsyg1 \
    --MAP_TITLE_OFFSET=0.8c \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --FONT_LABEL=8p,25,black \
    --FONT_TITLE=16p,13,black \
    -B+t"Topographic map of Rwanda" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx14.5c/-2.5c+c10+w50k+l"Mercator projection. Scale (km)"+f \
    -UBL/0p/-70p -O -K >> $ps

# Texts
# Lakes
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,white+jLB >> $ps << EOF
29.2 -1.95 Lake
29.2 -2.05 Kivu
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,white+jLB >> $ps << EOF
30.32 -2.32 Lake
30.32 -2.37 Rweru
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,white+jLB >> $ps << EOF
30.75 -1.81 Lake
30.75 -1.86 Ihema
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,white+jLB >> $ps << EOF
30.31 -2.05 Lake
30.31 -2.10 Mugesera
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,white+jLB >> $ps << EOF
30.4 -1.85 Lake Muhazi
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,white+jLB >> $ps << EOF
29.78 -1.45 Lake Burera
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,white+jLB >> $ps << EOF
29.74 -1.51 Lake Ruhondo
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,white+jLB >> $ps << EOF
30.0 -2.25 Lake
29.9 -2.3 Cyohoha South
EOF

# countries
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,0,black+jLB -Gwhite@60 >> $ps << EOF
29.4 -1.1 U  G  A  N  D  A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,0,black+jLB -Gwhite@60 >> $ps << EOF
29.4 -2.9 B U R U N D I
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,0,black+jLB -Gwhite@60 >> $ps << EOF
30.55 -2.65 T A N Z A N I A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,0,black+jLB -Gwhite@60 >> $ps << EOF
28.6 -1.6 C O N G O
28.6 -1.7 (D.R.C.)
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,26,white+jLB >> $ps << EOF
29.6 -2.2 R    W    A    N    D    A
EOF
# Cities
gmt pstext -R -J -N -O -K \
-F+f13p,0,black+jLB -Gwhite@60 >> $ps << EOF
30.08 -1.90 Kigali
EOF
gmt psxy -R -J -Ss -W0.5p -Gred -O -K << EOF >> $ps
30.06 -1.94 0.40c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@60 >> $ps << EOF
30.00 -1.5 Byumba
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
30.06 -1.57 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@60 >> $ps << EOF
29.70 -2.30 Nyanza
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
29.73 -2.35 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@60 >> $ps << EOF
30.44 -1.97 Rwamagana
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
30.43 -1.95 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@60 >> $ps << EOF
29.70 -2.04 Muhanga
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
29.75 -2.08 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@60 >> $ps << EOF
29.36 -2.03 Kibuye
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
29.35 -2.06 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@60 >> $ps << EOF
29.70 -2.55 Butare
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
29.75 -2.6 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@60 >> $ps << EOF
28.90 -2.46 Cyangugu
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
28.89 -2.48 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@60 >> $ps << EOF
30.56 -2.10 Kibungo
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
30.54 -2.15 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@60 >> $ps << EOF
30.33 -1.31 Nyagatare
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
30.32 -1.29 0.20c
EOF

# insert map
# Countries codes: ISO 3166-1 alpha-2. Continent codes AF (Africa), AN (Antarctica), AS (Asia), EU (Europe), OC (Oceania), NA (North America), or SA (South America). -EEU+ggrey
gmt psbasemap -R -J -O -K -DjTL+w3.2c+o-0.2c/-0.2c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thin,grey -Rg -JG28.0/-2.0S/$w -Da -Glightgoldenrod1 -A5000 -Bga -Wfaint -ERW+gred -Sdodgerblue -O -K -X$x0 -Y$y0 >> $ps
#gmt pscoast -Rg -JG12/5N/$w -Da -Gbrown -A5000 -Bg -Wfaint -ECM+gbisque -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx7.0/-3.1+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y8.0c -N -O \
    -F+f10p,0,black+jLB >> $ps << EOF
3.0 9.0 Digital elevation data: SRTM/GEBCO, 15 arc sec resolution grid
EOF

# Convert to image file using GhostScript
gmt psconvert Topo_RW.ps -A0.5c -E720 -Tj -Z
