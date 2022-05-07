#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: Sweden, Sundsvall region)
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert
# http://soliton.vm.bytemark.co.uk/pub/cpt-city/njgs/index.html

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
# gmt grdcut ETOPO1_Ice_g_gmt4.grd -R16/20/61.5/63.5 -Gse_sundsvall_relief1.nc
gmt grdcut GEBCO_2019.nc -R16/20/61.5/63.5 -Gse_sundsvall_relief.nc
gdalinfo -stats se_sundsvall_relief.nc
# Minimum=-269.000, Maximum=565.000

# Make color palette
#gmt makecpt -Cgeo -V -T-698/1603 > pauline.cpt
#gmt makecpt -Carctic -V -T-698/1603 > pauline.cpt
#gmt makecpt -Cibcao -V -T-698/1603 > pauline.cpt
#gmt makecpt -CETOPO1 -V -T-698/1603 > pauline.cpt
#gmt makecpt -Cworld -V -T-698/1603 > pauline.cpt
#gmt makecpt -Cturbo -V -T-698/1603 > pauline.cpt
#gmt makecpt -Cglobe -V -T-269/565 > pauline.cpt
gmt makecpt -Cgeo -V -T-269/565 > pauline.cpt
# elevation etopo1 world dem1 dem2 dem3 globe geo srtm turbo terra earth relief costa-rica

ps=Topo_SEsund.ps
# Make background transparent image
gmt grdimage se_sundsvall_relief.nc -Cpauline.cpt -R16/20/61.5/63.5 -JM5.0i -I+a15+ne0.75 -t0 -Xc -P -K > $ps
    
# Add isolines
gmt grdcontour se_sundsvall_relief.nc -R -J -C100 -A500+f7p,26,darkbrown -Wthinner,darkbrown -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,red -W0.1p -Df -O -K >> $ps
    
# Add color legend
gmt psscale -Dg16.0/61.28+w12.0c/0.15i+h+o0.3/0i+ml+e -R -J -Cpauline.cpt \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_TITLE=6p,0,black \
    -Bg100f10a100+l"Colormap: 'globe' scheme for bathymetry/topography. [R=-698/1603, H, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=WEsN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    -Bpxg1f0.5a0.5 -Bpyg1f0.5a0.5 -Bsxg1 -Bsyg1 \
    --MAP_TITLE_OFFSET=0.8c \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --FONT_LABEL=8p,25,black \
    --FONT_TITLE=14p,25,black \
    -B+t"Topographic map of the Sundsvall region, Baltic Sea" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx10.5c/-1.6c+c10+w200k+l"Mercator Projection. Scale (km)"+f \
    -UBL/0p/-50p -O -K >> $ps

# Texts
# countries
gmt pstext -R -J -N -O -K \
-F+jTL+f16p,25,black+jLB -Gwhite@40 >> $ps << EOF
16.5 62.8 S  W  E  D  E  N
EOF

# Sea
gmt pstext -R -J -N -O -K \
-F+jTL+f17p,26,white+jLB >> $ps << EOF
19.2 62.7 Baltic
19.3 62.6 Sea
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f16p,0,blue2+jLB >> $ps << EOF
18.3 62.05 Bothnian Bay
18.3 61.90 (Bottenhavet)
EOF
# Cities
gmt pstext -R -J -N -O -K \
-F+f14p,1,black+jLB+a-0 -Gwhite@60 >> $ps << EOF
17.30 62.38 Sundsvall
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
17.31 62.35 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f14p,1,black+jLB -Gwhite@60 >> $ps << EOF
17.35 62.50 Timrå
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
17.33 62.48 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,0,black+jLB -Gwhite@50 >> $ps << EOF
18.31 62.95 Nordingrå
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
18.29 62.93 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,0,black+jLB -Gwhite@50 >> $ps << EOF
17.85 62.70 Älandsbro
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
17.83 62.66 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f15p,0,black+jLB+a-0 -Gwhite@50 >> $ps << EOF
17.47 62.3 Alnön Island
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,0,black+jLB+a-0 -Gwhite@50 >> $ps << EOF
17.15 61.75 Hudiksvall
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
17.12 61.73 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,0,black+jLB -Gwhite@50 >> $ps << EOF
17.15 61.62 Njutånger
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
17.05 61.62 0.20c
EOF

# Add GMT logo
gmt logo -Dx4.5/-2.3+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.c -Y8.5c -N -O \
    -F+f10p,0,black+jLB >> $ps << EOF
1.0 9.0 Digital elevation data: GEBCO grid, 15 arc sec (ca. 450 m) resolution
EOF

# Convert to image file using GhostScript
gmt psconvert Topo_SEsund.ps -A0.5c -E720 -Tj -Z
