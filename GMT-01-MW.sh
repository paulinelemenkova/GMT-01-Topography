#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: Malawi)
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
#gmt grdcut ETOPO1_Ice_g_gmt4.grd -R32/36/-17.5/-9 -Gmw_relief.nc
gmt grdcut GEBCO_2019.nc -R32/36/-17.5/-9 -Gmw_relief.nc
gdalinfo -stats mw_relief.nc
# Minimum=36.000, Maximum=2846.000

# Make color palette
gmt makecpt -Cdem2.cpt -V -T36/2846 > pauline.cpt
# elevation etopo1 world elevation dem1 dem2 dem3 globe geo srtm turbo terra earth

#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R32/36/-17.5/-9 -JM5.0i -Dh -M -EMW > Malawi.txt
#gmt pscoast -Dh -M -ELB > Malawi.txt
#####################################################################

ps=Topo_MW.ps
# Make background transparent image
gmt grdimage mw_relief.nc -Cpauline.cpt -R32/36/-17.5/-9 -JM5.0i -I+a15+ne0.75 -t50 -Xc -P -K > $ps
    
# Add isolines
#gmt grdcontour mw_relief.nc -R -J -C500 -A1000+f7p,26,darkbrown -Wthinner,darkbrown -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thick,dimgray -W0.1p -Df -O -K >> $ps
    
#####################################################################
# CLIPPING
# 1. Start: clip the map by mask to only include country
#gmt psclip -JM -R Malawi.txt -O -K >> $ps

gmt psclip -R32/36/-17.5/-9 -JM5.0i Malawi.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage mw_relief.nc -Cpauline.cpt -R32/36/-17.5/-9 -JM5.0i -I+a15+ne0.75 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour mw_relief.nc -R -J -C500 -Wthinnest,darkbrown -O -K >> $ps
# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thick,dimgray -W0.1p -Df -O -K >> $ps
#gmt pscoast -R -J \
    -Ia/thinner,blue -Na -W0.1p -Df -O -K >> $ps

# 3: Undo the clipping
gmt psclip -C -O -K >> $ps
#####################################################################
    
# Add color legend
gmt psscale -Dg32/-17.9+w12.0c/0.15i+h+o0.3/0i+ml+e -R -J -Cpauline.cpt \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_TITLE=6p,0,black \
    -Bg500f50a500+l"Colormap: 'turbo' Google's Improved Rainbow CPT [R=-3481/4326, H=0, C=HSV]" \
    -I0.2 -By+lm -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=WEsN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    --MAP_TITLE_OFFSET=0.8c \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --FONT_LABEL=8p,25,black \
    --FONT_TITLE=16p,13,black \
    -Bpxg2f1a0.5 -Bpyg2f1a0.5 -Bsxg2 -Bsyg1 \
    -B+t"Topographic map of Malawi" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx11.0c/-2.5c+c10+w75k+l"Mercator projection. Scale (km)"+f \
    -UBL/0p/-70p -O -K >> $ps

# Texts
# lake
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,26,white+jLB+a-80 >> $ps << EOF
34.3 -10.8 L a k e
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,26,white+jLB+a-70 >> $ps << EOF
34.1 -12.1 M a l a w i
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,26,white+jLB+a-85 >> $ps << EOF
34.35 -12.9 (N y a s a)
EOF
# countries
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,0,black+jLB -Gwhite@60  >> $ps << EOF
32.2 -12.8 Z A M B I A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,0,black+jLB -Gwhite@60 >> $ps << EOF
32.4 -16.3 M O Z A M B I Q U E
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,0,black+jLB -Gwhite@60 >> $ps << EOF
34.8 -12.5 MOZAMBIQUE
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,0,black+jLB -Gwhite@60 >> $ps << EOF
32.15 -17.2 ZIMBABWE
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,0,black+jLB -Gwhite@60 >> $ps << EOF
35.0 -10.7 TANZANIA
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f16p,13,black+jLB -Gwhite@40  >> $ps << EOF
33.6 -14.2 M  A  L  A  W  I
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,26,blue2+jLB+a-320 -Gwhite@60 >> $ps << EOF
33.5 -13.3 Bua River
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,26,blue2+jLB+a-306 >> $ps << EOF
32.25 -12.1 Luangwa
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,26,blue2+jLB+a-302 >> $ps << EOF
32.7 -11.6 River
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,26,blue2+jLB+a-60 -Gwhite@70 >> $ps << EOF
32.7 -14.9 Zambezi River
EOF

# Cities
gmt pstext -R -J -N -O -K \
-F+f13p,0,black+jLB -Gwhite@40 >> $ps << EOF
33.85 -13.85 Lilongwe
EOF
gmt psxy -R -J -Ss -W0.5p -Gred -O -K << EOF >> $ps
33.8 -13.9 0.40c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@40 >> $ps << EOF
35.05 -15.75 Blantyre
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
35.0 -15.8 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@40 >> $ps << EOF
34.05 -11.35 Mzuzu
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
34.0 -11.4 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@40 >> $ps << EOF
35.25 -15.35 Zomba
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
35.2 -15.4 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@40 >> $ps << EOF
33.75 -9.75 Karonga
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
33.7 -9.8 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@40 >> $ps << EOF
33.15 -12.95 Kasungu
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
33.3 -13.0 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@40 >> $ps << EOF
35.3 -14.45 Mangochi
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
35.25 -14.5 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@40 >> $ps << EOF
34.45 -13.65 Salima
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
34.4 -13.7 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@40 >> $ps << EOF
35.12 -14.95 Liwonde
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
35.1 -15.0 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@40 >> $ps << EOF
34.75 -14.45 Balaka
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
34.7 -14.5 0.20c
EOF

# insert map
# Countries codes: ISO 3166-1 alpha-2. Continent codes AF (Africa), AN (Antarctica), AS (Asia), EU (Europe), OC (Oceania), NA (North America), or SA (South America). -EEU+ggrey
gmt psbasemap -R -J -O -K -DjTR+w4.5c+o-0.2c/-0.2c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thin,grey -Rg -JG34.0/-13.0N/$w -Da -Glightgoldenrod1 -A5000 -Bga -Wfaint -EMW+gred -Sdodgerblue -O -K -X$x0 -Y$y0 >> $ps
#gmt pscoast -Rg -JG12/5N/$w -Da -Gbrown -A5000 -Bg -Wfaint -ECM+gbisque -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx5.0/-3.1+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y21.5c -N -O \
    -F+f10p,0,black+jLB >> $ps << EOF
0.5 10.3 Digital elevation data: SRTM/GEBCO, 15 arc sec resolution grid
EOF

# Convert to image file using GhostScript
gmt psconvert Topo_MW.ps -A3.5c -E720 -Tj -Z
