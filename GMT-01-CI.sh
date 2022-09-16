#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: Côte d’Ivoire)
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
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R-9/-2/4/11 -Gci1_relief.nc
gmt grdcut GEBCO_2019.nc -R-9/-2/4/11 -Gci_relief.nc
gdalinfo -stats ci_relief.nc
# Topography: actual_range={-3746/1398}

# Make color palette
gmt makecpt -Cgeo.cpt -V -T-3746/1398 > pauline.cpt
# elevation etopo1 world elevation dem1 dem2 dem3 globe geo srtm turbo terra earth

#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R-9/-2/4/11 -JM5.5i -Dh -M -ECI > CotdIvoire.txt
#####################################################################

ps=Topo_CI.ps
# Make background transparent image
gmt grdimage ci_relief.nc -Cpauline.cpt -R-9/-2/4/11 -JM5.5i -I+a15+ne0.75 -t40 -Xc -P -K > $ps
    
# Add isolines
gmt grdcontour ci1_relief.nc -R -J -C1000 -A1000+f7p,26,darkbrown -Wthinner,darkbrown -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thick,dimgray -W0.1p -Df -O -K >> $ps
    
#####################################################################
# CLIPPING
# 1. Start: clip the map by mask to only include country

gmt psclip -R-9/-2/4/11 -JM5.5i CotdIvoire.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage ci_relief.nc -Cpauline.cpt -R-9/-2/4/11 -JM5.5i -I+a15+ne0.75 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour ci1_relief.nc -R -J -C500 -Wthinnest,darkbrown -O -K >> $ps
# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps
#gmt pscoast -R -J \
    -Ia/thinner,blue -Na -W0.1p -Df -O -K >> $ps

# 3: Undo the clipping
gmt psclip -C -O -K >> $ps
#####################################################################
    
# Add color legend
gmt psscale -Dg-9.2/3.4+w14.0c/0.15i+h+o0.3/0i+ml+e -R -J -Cpauline.cpt \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_TITLE=6p,0,black \
    -Bg500f50a1000+l"Colormap: 'geo' Colors for global bathymetry/topography relief [R=-3746/1398, H, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=WEsN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    --MAP_TITLE_OFFSET=0.7c \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --FONT_LABEL=8p,25,black \
    --FONT_TITLE=13p,0,black \
        -Bpxg2f1a1 -Bpyg2f1a1 -Bsxg2 -Bsyg1 \
    -B+t"Topographic map of Côte d'Ivoire" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx11.7c/-2.4c+c10+w250k+l"Mercator projection. Scale (km)"+f \
    -UBL/0p/-70p -O -K >> $ps

# Texts
# Cities -R-9/-2/4/11
gmt pstext -R -J -N -O -K \
-F+f12p,22,black+jLB -Gwhite@50 >> $ps << EOF
-5.30 6.90 Yamoussoukro
EOF
gmt psxy -R -J -Ss -W0.5p -Gred -O -K << EOF >> $ps
-5.27 6.80 0.30c
EOF
#
gmt pstext -R -J -N -O -K \
-F+f13p,21,black+jLB -Gwhite@50 >> $ps << EOF
-4.09 5.45 Abidjan
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-4.09 5.35 0.20c
EOF
#
gmt pstext -R -J -N -O -K \
-F+f13p,21,black+jLB -Gwhite@50 >> $ps << EOF
-5.05 7.78 Bouaké
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-5.02 7.68 0.20c
EOF
#
gmt pstext -R -J -N -O -K \
-F+f13p,21,black+jLB -Gwhite@50 >> $ps << EOF
-5.90 6.53 Daloa
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-5.88 6.45 0.20c
EOF
#
gmt pstext -R -J -N -O -K \
-F+f13p,21,black+jLB -Gwhite@50 >> $ps << EOF
-6.80 4.85 San-Pédro
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-6.63 4.75 0.20c
EOF
#
gmt pstext -R -J -N -O -K \
-F+f13p,21,black+jLB -Gwhite@50 >> $ps << EOF
-5.40 5.93 Divo
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-5.37 5.83 0.20c
EOF
#
gmt pstext -R -J -N -O -K \
-F+f13p,21,black+jLB -Gwhite@70 >> $ps << EOF
-5.70 9.52 Korhogo
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-5.62 9.42 0.20c
EOF
#
gmt pstext -R -J -N -O -K \
-F+f13p,21,black+jLB -Gwhite@50 >> $ps << EOF
-4.4 6.50 Abengourou
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-3.48 6.73 0.20c
EOF
#
gmt pstext -R -J -N -O -K \
-F+f13p,21,black+jLB -Gwhite@60 >> $ps << EOF
-6.72 8.07 Séguéla
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-6.66 7.97 0.20c
EOF
#
gmt pstext -R -J -N -O -K \
-F+f13p,21,black+jLB -Gwhite@50 >> $ps << EOF
-5.10 8.25 Katiola
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-5.15 8.15 0.20c
EOF
#
gmt pstext -R -J -N -O -K \
-F+f13p,21,black+jLB -Gwhite@50 >> $ps << EOF
-6.00 6.23 Gagnoa
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-5.93 6.13 0.20c
EOF
# countries
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,25,black+jLB -Gwhite@60 >> $ps << EOF
-8.8 5.5 L I B E R I A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,25,black+jLB -Gwhite@60 >> $ps << EOF
-8.9 8.5 G U I N E A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,25,black+jLB -Gwhite@50 >> $ps << EOF
-7.5 10.7 M A L I
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,25,black+jLB -Gwhite@70 >> $ps << EOF
-4.8 10.5 B U R K I N A
-4.5 10.3 F A S O
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,25,black+jLB -Gwhite@60 >> $ps << EOF
-3.0 6.4 G H A N A
EOF

gmt pstext -R -J -N -O -K \
-F+jTL+f19p,31,black+jLB -Gwhite@75 >> $ps << EOF
-7.7 7.3 C  Ô  T  E    D\'   I  V  O  I  R  E
EOF
# water
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,white+jLB >> $ps << EOF
-4.7 4.4 Gulf of Guinea
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,white+jLB >> $ps << EOF
-6.2 4.1 A  t  l  a  n  t  i  c     O  c  e  a  n
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,blue2+jLB >> $ps << EOF
-5.8 7.1 Lac de Kossou
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,blue2+jLB >> $ps << EOF
-7.4 6.6 Lac de
-7.3 6.4 Buyo
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,blue2+jLB+a-50 >> $ps << EOF
-7.0 5.9 Sassandra
EOF

# insert map
# Countries codes: ISO 3166-1 alpha-2. Continent codes AF (Africa), AN (Antarctica), AS (Asia), EU (Europe), OC (Oceania), NA (North America), or SA (South America). -EEU+ggrey
gmt psbasemap -R -J -O -K -DjTR+w2.7c+o-0.2c/-0.2c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thin,grey -Rg -JG-1.0/8.0N/$w -Da -Glightgoldenrod1 -A5000 -Bga -Wfaint -ECI+gred -Sdodgerblue -O -K -X$x0 -Y$y0 >> $ps
#gmt pscoast -Rg -JG12/5N/$w -Da -Gbrown -A5000 -Bg -Wfaint -ECM+gbisque -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx6.0/-3.1+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y7.8c -N -O \
    -F+f10p,0,black+jLB >> $ps << EOF
01.5 10.3 Digital elevation data: SRTM/GEBCO, 15 arc sec resolution grid
EOF

# Convert to image file using GhostScript
gmt psconvert Topo_CI.ps -A0.5c -E720 -Tj -Z
