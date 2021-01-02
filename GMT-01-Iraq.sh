#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: Iraq)
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
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R38/49/29/38 -Giq_relief1.nc
gmt grdcut GEBCO_2019.nc -R38/49/29/38 -Giq_relief.nc
gdalinfo -stats iq_relief.nc
#  Minimum=-69.000, Maximum=3754.000

# Make color palette
gmt makecpt -Cgeo.cpt -V -T-69/3754 > myocean.cpt

ps=Topo_IQ.ps
# Make raster image
gmt grdimage iq_relief.nc -Cmyocean.cpt -R38/49/29/38 -JM6.5i -I+a15+ne0.75 -Xc -K > $ps

# Add legend
gmt psscale -Dg36.7/29.0+w16.0c/0.15i+v+o0.3/0i+ml -R -J -Cmyocean.cpt \
	--FONT_LABEL=7p,0,black \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_TITLE=6p,0,black \
	-Bg500f50a500+l"Color scale: geo [R=-3637/4124, H=0, C=HSV]" \
	-I0.2 -By+lm -O -K >> $ps
    
# Add isolines
gmt grdcontour iq_relief1.nc -R -J -C500 -Wthinner,darkbrown -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P \
    -Ia/thinner,blue -Na -N1/thickest,red -W0.1p -Df -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=wESN \
    --MAP_TITLE_OFFSET=1.0c \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_LABEL=7p,25,black \
    --FONT_TITLE=12p,25,black \
    -Bpxg4f1a2 -Bpyg2f1a2 -Bsxg2 -Bsyg1 \
    -B+t"Topographic map of Iraq and its global location" -O -K >> $ps
    
# Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=7p,0,black \
    --FONT_ANNOT_PRIMARY=6p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx14.5c/-1.3c+c50+w200k+l"Mercator projection. Scale (km)"+f \
    -UBL/-15p/-38p -O -K >> $ps

gmt psbasemap -R -J \
    --FONT_TITLE=7p,0,white \
    --MAP_TITLE_OFFSET=0.1c \
    -Tdx0.5c/0.4c+w1.0c+f2+l+o0.15i \
    -O -K >> $ps

# Texts
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,26,azure+jLB+a-55 >> $ps << EOF
46.2 32.4 Tigris
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,26,azure+jLB+a-15 >> $ps << EOF
44.7 31.1 Euphrates
EOF
#
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,26,blue2+jLB >> $ps << EOF
42.5 32.7 Buhayrat
42.5 32.5 Ar Razazah
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,26,blue2+jLB >> $ps << EOF
42.6 33.3 Lake
42.6 33.1 Habbaniyah
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,26,blue2+jLB >> $ps << EOF
43.3 34.3 Buhayrat
43.3 34.1 ath-Tharthar
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,0,royalblue4+jLB+a-320 >> $ps << EOF
48.3 29.1 Persian
48.6 29.1 Gulf
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,13,khaki1+jLB >> $ps << EOF
44.6 33.1 Baghdad
EOF
gmt psxy -R -J -Ss -W0.5p -Gred -O -K << EOF >> $ps
44.5 33.0  0.4c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,black+jLB >> $ps << EOF
42.7 36.1 Mosul
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
43.0 36.0 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,white+jLB >> $ps << EOF
47.3 30.4 Basra
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
47.5 30.7 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,black+jLB >> $ps << EOF
43.6 35.1 Kirkuk
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
44.0 35.0 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,black+jLB >> $ps << EOF
43.7 36.1 Erbil
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
44.0 36.0 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,honeydew1+jLB >> $ps << EOF
44.1 32.1 Najaf
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
44.2 32.0 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,honeydew1+jLB >> $ps << EOF
44.0 32.5 Karbala
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
43.9 32.4 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,black+jLB -Gwhite@75 >> $ps << EOF
44.6 35.1 Sulaymaniya
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
45.0 35.0 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,white+jLB >> $ps << EOF
46.0 31.1 Al Nasiriya
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
46.0 31.0 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,white+jLB >> $ps << EOF
46.8 30.8 Al Amarah
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
47.0 31.0 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,25,firebrick3+jLB -Gwhite@30 -Wthinnest >> $ps << EOF
46.7 36.5 I R A N
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,25,ivory1+jLB >> $ps << EOF
38.9 30.5 S A U D I  A R A B I A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,25,red+jLB >> $ps << EOF
38.5 35.5 S Y R I A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,25,ivory1+jLB >> $ps << EOF
38.1 32.4 JORDAN
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,25,firebrick3+jLB -Gwhite@30 >> $ps << EOF
40.6 37.5 T U R K E Y
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f17p,25,khaki1+jLB >> $ps << EOF
42.5 33.5 I      R      A      Q
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,13,lightyellow+jLB >> $ps << EOF
40.1 33.1 Syrian
40.1 32.7 Desert
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,13,orangered4+jLB+a-45 -Gwhite@40 >> $ps << EOF
43.6 37.0 Jabal Hamrin
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,13,darkorange4+jLB >> $ps << EOF
41.6 35.2 Al-Jazira
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,13,red4+jLB+a-47 -Gwhite@40 >> $ps << EOF
45.3 37.0 Z a g r o s
47.0 35.4 M o u n t a i n s
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,13,tomato4+jLB >> $ps << EOF
42.1 29.2 Ad-Dibdiba
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,25,white+jLB+a-330 >> $ps << EOF
47.0 29.2 KUWAIT
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,13,darkorange4+jLB+a-350 >> $ps << EOF
41.3 36.1 Jabal Sinjar
EOF

# insert map
# Countries codes: ISO 3166-1 alpha-2. Continent codes AF (Africa), AN (Antarctica), AS (Asia), EU (Europe), OC (Oceania), NA (North America), or SA (South America). -EEU+ggrey
gmt psbasemap -R -J -O -K -DjTL+w3.2c+o-0.2c/-0.2c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thin,grey -Rg -JG43.5/33.5N/$w -Da -Glightgoldenrod1 -A5000 -Bga -Wfaint -EIQ+gred -Sdodgerblue -O -K -X$x0 -Y$y0 >> $ps
#gmt pscoast -Rg -JG12/5N/$w -Da -Gbrown -A5000 -Bg -Wfaint -ECM+gbisque -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx7.0/-2.0+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y11.0c -N -O \
    -F+f10p,25,black+jLB >> $ps << EOF
3.0 9.0 Digital elevation data: SRTM/GEBCO, 15 arc sec resolution grid
EOF

# Convert to image file using GhostScript
gmt psconvert Topo_IQ.ps -A0.2c -E720 -Tj -Z
