#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: Yemen)
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
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R42/55/10/20 -Gye_relief1.nc
gmt grdcut GEBCO_2019.nc -R42/55/10/20 -Gye_relief.nc
gdalinfo -stats ye_relief.nc
#  Minimum=-5358.000, Maximum=3447.000

# Make color palette
gmt makecpt -Cglobe.cpt -V -T-5358/3447 > myocean.cpt

ps=Topo_YE.ps
# Make raster image
gmt grdimage ye_relief.nc -Cmyocean.cpt -R42/55/10/20 -JM6.5i -I+a15+ne0.75 -Xc -K > $ps

# Add legend
gmt psscale -Dg40.5/10.0+w13.0c/0.15i+v+o0.3/0i+ml -R -J -Cmyocean.cpt \
	--FONT_LABEL=7p,0,black \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_TITLE=6p,0,black \
	-Bg500f50a500+l"Color scale: 'globe' [R=-5358/3447, H=0, C=HSV]" \
	-I0.2 -By+lm -O -K >> $ps
    
# Add isolines
gmt grdcontour ye_relief1.nc -R -J -C500 -Wthinner,darkbrown -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P \
    -Ia/thinner,blue -Na -N1/thickest,red -W0.1p -Df -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=wESN \
    --MAP_TITLE_OFFSET=1.0c \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_LABEL=7p,25,black \
    --FONT_TITLE=13p,13,black \
    -Bpxg4f1a2 -Bpyg2f1a2 -Bsxg2 -Bsyg1 \
    -B+t"Topographic map of Yemen and Gulf of Aden" -O -K >> $ps
    
# Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=7p,0,black \
    --FONT_ANNOT_PRIMARY=6p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx14.5c/-1.3c+c50+w200k+l"Mercator projection. Scale (km)"+f \
    -UBL/-15p/-38p -O -K >> $ps

# Texts
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,25,red+jLB+a-340 >> $ps << EOF
53.0 17.8 O    M    A    N
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,25,red+jLB+a-340 >> $ps << EOF
46.1 17.8 S  A  U  D  I     A  R  A  B  I  A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,25,red+jLB+a-330 -Gwhite@30 >> $ps << EOF
42.1 11.5 DJIBOUTI
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,25,red+jLB+a-350 -Gwhite@60 >> $ps << EOF
47.0 10.3 S   O   M   A   L   I
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f16p,25,white+jLB+a-340 >> $ps << EOF
46.3 15.9 Y        E        M        E        N
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,25,red+jLB+a-50 -Gwhite@30 >> $ps << EOF
42.0 13.4 ERITREA
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f7p,25,red+jLB+a-60 -Gwhite@30 >> $ps << EOF
42.0 10.9 ETHIOPIA
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,13,blue+jLB+a-340 -Gwhite@50 >> $ps << EOF
46.5 11.7 G u l f   o f   A d e n
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,13,royalblue4+jLB -Gwhite@50 >> $ps << EOF
53.4 15.5 Arabian
53.7 15.1 Sea
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,13,royalblue4+jLB -Gwhite@50 >> $ps << EOF
53.7 10.8 Indian
53.6 10.4 Ocean
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,26,blue2+jLB+a-60 -Gwhite@70 >> $ps << EOF
42.9 13.4 Bab-el-Mandeb
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,26,chocolate4+jLB+a-340 >> $ps << EOF
46.1 18.7 A R   R U B'  A L  K H A L I
46.5 18.5 (Empty Quarter Desert)
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,blue2+jLB+a-82 -Gwhite@70 >> $ps << EOF
42.2 16.5 R e d   S e a
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,13,brown4+jLB -Gwhite@30 >> $ps << EOF
53.5 12.0 Socotra
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,13,darkbrown+jLB+a-345 -Gwhite@70 >> $ps << EOF
47.7 15.1 H A D H R A M A U T
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,13,khaki1+jLB+a-18 >> $ps << EOF
51.0 17.1 Jabal Mahra
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,khaki1+jLB >> $ps << EOF
50.1 16.8 Jabal Bin
50.1 16.5 Kushayt
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,khaki1+jLB+a-45 >> $ps << EOF
44.6 17.3 Ramlat Dahm
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,khaki1+jLB+a-330 >> $ps << EOF
46.4 15.3 Ramlat
46.4 15.0 al-Sab'atayn
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,13,khaki1+jLB >> $ps << EOF
43.3 15.2 Jabal
43.3 14.9 Haraz
EOF
# cities
gmt pstext -R -J -N -O -K \
-F+f11p,13,black+jLB -Gwhite@30 >> $ps << EOF
44.2 15.4 Sana'a
EOF
gmt psxy -R -J -Ss -W0.5p -Gred -O -K << EOF >> $ps
44.1 15.2 0.40c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,black+jLB -Gwhite@30 >> $ps << EOF
45.1 13.1 Aden
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
45.0 13.0 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,13,black+jLB -Gwhite@30 >> $ps << EOF
44.2 13.2 Taiz
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
44.0 13.3 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,13,black+jLB -Gwhite@30 >> $ps << EOF
43.1 14.6 Al Hudaydah
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
43.0 14.5 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,13,black+jLB -Gwhite@30 >> $ps << EOF
44.2 13.7 Ibb
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
44.1 13.6 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,black+jLB -Gwhite@30 >> $ps << EOF
49.1 14.4 Al Mukalla
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
49.0 14.3 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,13,black+jLB -Gwhite@30 >> $ps << EOF
44.3 14.4 Dhamar
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
44.2 14.3 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,13,black+jLB -Gwhite@30 >> $ps << EOF
43.3 15.6 Amran
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
43.6 15.4 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,13,black+jLB -Gwhite@30 >> $ps << EOF
43.5 16.7 Sadah
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
43.4 16.6 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,black+jLB -Gwhite@30 >> $ps << EOF
52.2 16.2 Al Ghaydah
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
52.1 16.1 0.20c
EOF

# insert map
# Countries codes: ISO 3166-1 alpha-2. Continent codes AF (Africa), AN (Antarctica), AS (Asia), EU (Europe), OC (Oceania), NA (North America), or SA (South America). -EEU+ggrey
gmt psbasemap -R -J -O -K -DjTL+w3.2c+o-0.2c/-0.2c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thin,grey -Rg -JG49.0/15.0N/$w -Da -Glightgoldenrod1 -A5000 -Bga -Wfaint -EYE+gred -Sdodgerblue -O -K -X$x0 -Y$y0 >> $ps
#gmt pscoast -Rg -JG12/5N/$w -Da -Gbrown -A5000 -Bg -Wfaint -ECM+gbisque -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx7.0/-2.0+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.1c -Y8.0c -N -O \
    -F+f10p,13,black+jLB >> $ps << EOF
3.0 9.0 Digital elevation data: SRTM/GEBCO, 15 arc sec resolution grid
EOF

# Convert to image file using GhostScript
gmt psconvert Topo_YE.ps -A0.2c -E720 -Tj -Z
