#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO dataset (here: Peru)
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
    FONT_ANNOT_PRIMARY=7p,Helvetica,dimgray \
    FONT_LABEL=7p,Helvetica,dimgray
# Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults

#LON LAT
gmt grdcut GEBCO_2019.nc -R18/24/41/47 -Gserbia_relief.nc
#gmt grdcut ETOPO1_Ice_g_gmt4.grd -R278/292/-21/3 -Gserbia_relief.nc
#263/278

gdalinfo serbia_relief.nc -stats
# Minimum=-1241.674, Maximum=2801.539
# Make color palette
# makecpt --help
gmt makecpt -Cgeo.cpt -V -T-1242/2802 > myocean.cpt
#gmt makecpt -Cwiki-albania -V -T-1242/2802 > myocean.cpt

# Generate a file
ps=Topo_RS.ps
# Make raster image
gmt grdimage serbia_relief.nc -Cmyocean.cpt -R18/24/41/47 -JM6i -P -I+a15+ne0.75 -Xc -K > $ps

# Add grid
gmt psbasemap -R -J \
    -Bpx1f0.5a1 -Bpyg1f0.5a1 -Bsxg1 -Bsyg1 \
    --MAP_TITLE_OFFSET=1c \
    --FONT_TITLE=15p,19,black \
    --FONT_ANNOT_PRIMARY=7p,Helvetica,black \
    -B+t"Topographic map of Serbia" -O -K >> $ps
    
# Add shorelines
gmt grdcontour serbia_relief.nc -R -J -C1000 -W0.1p -O -K >> $ps
    
# Add scale, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=10p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=8p,Helvetica,black \
    --MAP_LABEL_OFFSET=0.1c \
    -Lx12.7c/-2.3c+c50+w150k+l"Mercator projection. Scale: km"+f \
    -UBL/-5p/-65p -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P \
    -Ia/thinner,blue -Na -N1/thickest,red -W0.1p -Df -O -K >> $ps

# Add legend
gmt psscale -Dg18/40.6+w15.2c/0.4c+h+o0.0/0i+ml -R -J -Cmyocean.cpt \
    --FONT_LABEL=8p,Helvetica,black \
    --MAP_LABEL_OFFSET=0.1c \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,black \
        -Bg500f50a500+l"Color scale 'geo': global bathymetry/topography relief [R=-6857/3206, H=0, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps
    
# Texts
gmt pstext -R -J -N -O -K \
-F+jTL+f18p,19,black+jLB -Gwhite@80 >> $ps << EOF
19.25 44.35 S  E  R  B  I  A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,19,white+jLB >> $ps << EOF
20.02 44.87 Belgrade
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
20.46 44.81 0.30c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,white+jLB >> $ps << EOF
19.40 45.30 Novi Sad
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
19.85 45.25 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@60 >> $ps << EOF
20.38 44.55 Smederevo
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
20.93 44.67 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@60 >> $ps << EOF
20.40 44.07 Kragujevac
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
20.92 44.01 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,white+jLB >> $ps << EOF
19.52 46.02 Subotica
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
19.67 46.11 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,white+jLB >> $ps << EOF
20.25 45.28 Zrenjanin
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
20.39 45.38 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@50 >> $ps << EOF
21.50 42.90 Leskovac
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
21.95 43.00 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@60 >> $ps << EOF
21.95 42.50 Vranje
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
21.90 42.55 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@60 >> $ps << EOF
20.3 43.30 Novi
20.3 43.20 Pazar
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
20.52 43.14 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@60 >> $ps << EOF
20.4 43.60 Kraljevo
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
20.69 43.72 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,23,blue2+jLB+a-345 >> $ps << EOF
20.75 44.70 Danube
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,23,blue2+jLB+a-75 >> $ps << EOF
21.13 44.65 Velika
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,23,blue2+jLB+a-80 >> $ps << EOF
21.18 44.40 Morava
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,23,blue2+jLB+a-70 -Gwhite@70 >> $ps << EOF
21.80 43.5 Juzna
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,23,blue2+jLB+a-60 -Gwhite@70 >> $ps << EOF
21.90 43.25 Morava
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,23,blue2+jLB+a-30 -Gwhite@70 >> $ps << EOF
20.30 43.97 Zapadna Morava
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,23,blue2+jLB+a-30 >> $ps << EOF
19.74 44.8 Sava
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,23,blue2+jLB+a-83 >> $ps << EOF
20.2 45.9 Tisza
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,23,blue2+jLB+a-22 >> $ps << EOF
19.2 45.76 Veliki Kanal
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,25,black+jLB >> $ps << EOF
21.1 45.4 R O M A N I A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,25,black+jLB -Gwhite@60 >> $ps << EOF
23.05 42.4 B U L G A R I A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,25,black+jLB -Gwhite@60 >> $ps << EOF
21.2 41.8 M A C E D O N I A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,25,black+jLB -Gwhite@70 >> $ps << EOF
20.6 42.5 K O S O V O
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,25,black+jLB -Gwhite@70 >> $ps << EOF
19.6 41.85 A L B A N I A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,25,black+jLB -Gwhite@60 >> $ps << EOF
18.6 42.7 M O N T E N E G R O
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,25,black+jLB -Gwhite@60 >> $ps << EOF
18.1 44.5 B O S N I A
18.1 44.3 A N D
18.1 44.1 HERZEGOVINA
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,25,white+jLB >> $ps << EOF
18.1 45.4 C R O A T I A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,25,white+jLB >> $ps << EOF
19.05 46.5 H U N G A R Y
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,23,yellow+jLB+a-60 >> $ps << EOF
18.1 41.4 Adriatic
18.1 41.2 Sea
EOF
gmt pstext -R -J -N -O -K \
-F+f15p,20,yellow+jLB+a-40 >> $ps << EOF
18.8 43.95 D  I  N  A  R  I  C
19.3 43.25 A L P S
EOF
gmt pstext -R -J -N -O -K \
-F+f15p,20,yellow+jLB+a-60 >> $ps << EOF
21.5 44.2 B A L K A N   M T S
EOF

# insert map
# Countries codes: ISO 3166-1 alpha-2. Continent codes AF (Africa), AN (Antarctica), AS (Asia), EU (Europe), OC (Oceania), NA (North America), or SA (South America). -EEU+ggrey
gmt psbasemap -R -J -O -K -DjTR+w3.7c+o-0.2c/-0.2c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thin,grey -Rg -JG21/44n/$w -Da -Gpeachpuff -A5000 -Bg -Wfaint -ERS+gred -Slightskyblue1 -O -K -X$x0 -Y$y0 >> $ps
#gmt pscoast -Rg -JG12/5N/$w -Da -Gbrown -A5000 -Bg -Wfaint -ECM+gbisque -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx6.2/-3.0+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y12.9c -N -O \
    -F+f12p,Helvetica,black+jLB >> $ps << EOF
1.5 13.6 SRTM/GEBCO 15 arc sec resolution global terrain model grid
EOF

# Convert to image file using GhostScript
gmt psconvert Topo_RS.ps -A2.0c -E720 -Tj -Z
