#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: Tanzania)
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
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R29/42/-13/1 -Gtz_relief.nc
#gmt grdcut GEBCO_2019.nc -R29/42/-13/1 -Gtz_relief.nc
gdalinfo -stats tz_relief.nc
#  Minimum=-3510.000, Maximum=5677.000

# Make color palette
gmt makecpt -Cgeo.cpt -V -T-3510/5677 > myocean.cpt

ps=Topo_TZ.ps
# Make raster image
gmt grdimage tz_relief.nc -Cmyocean.cpt -R29/42/-13/1 -JM6.5i -I+a15+ne0.75 -Xc -K > $ps

# Add legend
gmt psscale -Dg27.5/-13.0+w17.7c/0.15i+v+o0.3/0i+ml -R -J -Cmyocean.cpt \
	--FONT_LABEL=7p,0,black \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_TITLE=6p,0,black \
	-Bg500f50a500+l"Color scale: 'geo' [R=-5358/3447, H=0, C=HSV]" \
	-I0.2 -By+lm -O -K >> $ps
    
# Add isolines
gmt grdcontour tz_relief.nc -R -J -C500 -Wthinner,darkbrown -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P \
    -Ia/thinner,blue -Na -N1/thickest,white -W0.1p -Df -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=wESN \
    --MAP_TITLE_OFFSET=0.8c \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_LABEL=7p,25,black \
    --FONT_TITLE=13p,13,black \
    -Bpxg4f1a2 -Bpyg2f1a2 -Bsxg2 -Bsyg1 \
    -B+t"Topographic map of Tanzania" -O -K >> $ps
    
# Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=7p,0,black \
    --FONT_ANNOT_PRIMARY=6p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx14.5c/-1.3c+c50+w200k+l"Mercator projection. Scale (km)"+f \
    -UBL/-15p/-38p -O -K >> $ps

# Texts
# Cities
gmt pstext -R -J -N -O -K \
-F+f10p,13,black+jLB -Gwhite@50 >> $ps << EOF
39.5 -6.1 Zanzibar City
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
39.3 -6.2 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,black+jLB -Gwhite@50 >> $ps << EOF
32.7 -4.9 Tabora
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
32.5 -5.0 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,white+jLB >> $ps << EOF
32.6 -3.4 Kahama
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
32.4 -3.5 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,white+jLB >> $ps << EOF
39.1 -4.9 Tanga
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
39.0 -5.0 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,black+jLB -Gwhite@50 >> $ps << EOF
37.5 -6.4 Morogoro
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
37.4 -6.5 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,black+jLB -Gwhite@50 >> $ps << EOF
33.4 -8.4 Mbeya
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
33.3 -8.5 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,13,black+jLB -Gwhite@50 >> $ps << EOF
35.6 -6.1 Dodoma
EOF
gmt psxy -R -J -Ss -W0.5p -Gred -O -K << EOF >> $ps
35.4 -6.1 0.35c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,black+jLB -Gwhite@50 >> $ps << EOF
36.5 -3.1 Arusha
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
36.4 -3.2 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,white+jLB >> $ps << EOF
32.5 -2.6 Mwanza
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
32.5 -2.3 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,black+jLB -Gwhite@50 >> $ps << EOF
39.2 -6.5 Dar es Salaam
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
39.1 -6.5  0.20c
EOF
# Lakes
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,13,blue+jLB+a-80 >> $ps << EOF
29.4 -5.1 Lake
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,13,blue+jLB+a-65  >> $ps << EOF
30.0 -6.8 Tanganyika
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,13,blue+jLB >> $ps << EOF
32.3 -0.9 Lake
32.2 -1.3 Victoria
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,13,blue+jLB+a-85 >> $ps << EOF
34.3 -10.2 Lake Nyasa
EOF
# countries
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,25,black+jLB+a-80 -Gdimgray@60 >> $ps << EOF
33.8 -11.1 MALAWI
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,25,chartreuse1+jLB -Gdimgray@60 >> $ps << EOF
30.3 -10.8 Z A M B I A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,25,chartreuse1+jLB -Gdimgray@60 >> $ps << EOF
29.1 -7.5 CONGO
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,25,chartreuse1+jLB -Gdimgray@60 >> $ps << EOF
29.4 -3.5 BURUNDI
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,25,chartreuse1+jLB -Gdimgray@60 >> $ps << EOF
29.5 -1.9 RWANDA
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,25,chartreuse1+jLB -Gdimgray@60 >> $ps << EOF
30.2 -0.5 U G A N D A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,25,chartreuse1+jLB -Gdimgray@60 >> $ps << EOF
37.0 -0.9 K E N Y A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f18p,13,white+jLB >> $ps << EOF
31.8 -5.7 T  A  N  Z  A  N  I  A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,25,black+jLB -Gwhite@60 >> $ps << EOF
36.1 -12.4 M O Z A M B I Q U E
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f13p,13,white+jLB >> $ps << EOF
40.5 -8.5 Indian
40.5 -9.5 Ocean
EOF

# insert map
# Countries codes: ISO 3166-1 alpha-2. Continent codes AF (Africa), AN (Antarctica), AS (Asia), EU (Europe), OC (Oceania), NA (North America), or SA (South America). -EEU+ggrey
gmt psbasemap -R -J -O -K -DjTR+w3.2c+o-0.2c/-0.2c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thin,grey -Rg -JG35.0/-6.0N/$w -Da -Glightgoldenrod1 -A5000 -Bga -Wfaint -ETZ+gred -Sdodgerblue -O -K -X$x0 -Y$y0 >> $ps
#gmt pscoast -Rg -JG12/5N/$w -Da -Gbrown -A5000 -Bg -Wfaint -ECM+gbisque -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx7.0/-2.0+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.1c -Y12.5c -N -O \
    -F+f10p,13,black+jLB >> $ps << EOF
3.0 9.0 Digital elevation data: SRTM/GEBCO, 15 arc sec resolution grid
EOF

# Convert to image file using GhostScript
gmt psconvert Topo_TZ.ps -A1.5c -E720 -Tj -Z
