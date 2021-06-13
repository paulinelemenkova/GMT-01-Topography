#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: Sweden)
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
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R3/26/54/70 -Gse_relief.nc
gmt grdcut GEBCO_2019.nc -R3/26/54/70 -Gse_relief1.nc
gdalinfo -stats se_relief.nc
#  Minimum=-3067.000, Maximum=2225.000, Mean=120.486, StdDev=446.592

#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R10/54/26/69.5r -JT17/4.5i -Dh -M -ESE > Sweden.txt
#####################################################################

# Make color palette
gmt makecpt -Cgeo -V -T-3067/2225 > pauline.cpt
# elevation etopo1 world elevation dem1 dem2 dem3 globe geo srtm turbo terra earth relief costa-rica

ps=Topo_SE.ps
# Make background transparent image
gmt grdimage se_relief1.nc -Cpauline.cpt -R10/54/26/69.5r -JT17/4.5i -I+a15+ne0.75 -t50 -Xc -P -K > $ps
    
# Add isolines
gmt grdcontour se_relief.nc -R -J -C500 -A1000+f7p,26,darkbrown -Wthinner,darkbrown -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,red -W0.1p -Df -O -K >> $ps
    
#####################################################################
# CLIPPING
# 1. Start: clip the map by mask to only include country
gmt psclip -R10/54/26/69.5r -JT17/4.5i Sweden.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage se_relief1.nc -Cpauline.cpt -R10/54/26/69.5r -JT17/4.5i -I+a15+ne0.75 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour se_relief.nc -R -J -C250 -Wthinnest,darkbrown -O -K >> $ps
# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps

# 3: Undo the clipping
gmt psclip -C -O -K >> $ps
#####################################################################
    
# Add color legend
gmt psscale -Dg9.5/53.2+w11.5c/0.15i+h+o0.3/0i+ml+e -R -J -Cpauline.cpt \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_TITLE=6p,0,black \
    -Bg500f50a500+l"Colormap: 'geo' scheme for topography. [R=-3067/2225, H, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=WEsN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    -Bpxg4f2a2 -Bpyg2f4a2 -Bsxg2 -Bsyg2 \
    --MAP_TITLE_OFFSET=0.8c \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --FONT_LABEL=8p,25,black \
    --FONT_TITLE=16p,25,black \
    -B+t"Topographic map of Sweden" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx9.5c/-2.5c+c10+w300k+l"Transverse Mercator Prj. Scale (km)"+f \
    -UBL/0p/-70p -O -K >> $ps

# Study area
# Rotated rectangle. kwargs: coords, direction degrees, x and y-dimension
gmt psxy -R -J -Sj1c -W2.0p,purple -O -K << EOF >> $ps
#11.5 57.0 315 3 6.0
11.5 57.5 15 1.5 2.8
EOF

# Texts
gmt pstext -R -J -N -O -K \
-F+jTL+f13p,26,purple+jLB+a-73 >> $ps << EOF
10.8 58.1 Study area
EOF

# countries
gmt pstext -R -J -N -O -K \
-F+jTL+f15p,25,black+jLB -Gwhite@60 >> $ps << EOF
12.5 63.0 S  W  E  D  E  N
EOF

# Sea
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,26,blue2+jLB >> $ps << EOF
18.0 56.2 Baltic
18.0 55.7 Sea
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f13p,26,blue2+jLB+a-359 >> $ps << EOF
18.0 61.8 Bothnian
19.0 61.3 Bay
EOF

# Cities
gmt pstext -R -J -N -O -K \
-F+f13p,0,black+jLB -Gwhite@40 >> $ps << EOF
18.35 59.20 Stockholm
EOF
gmt psxy -R -J -Ss -W0.5p -Gred -O -K << EOF >> $ps
18.07 59.33 0.40c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,white+jLB >> $ps << EOF
15.31 59.27 Örebro
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
15.21 59.27 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB+a-3 -Gwhite@60 >> $ps << EOF
12.07 57.50 Gothenburg
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
11.97 57.70 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,white+jLB >> $ps << EOF
16.68 59.47 Västerås
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
16.55 59.62 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,white+jLB >> $ps << EOF
12.82 56.15 Helsingborg
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
12.72 56.05 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,white+jLB >> $ps << EOF
13.10 55.48 Malmö
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
13.04 55.61 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,white+jLB >> $ps << EOF
15.25 58.70 Norrköping
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
16.2 58.6 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB+a-2 -Gwhite@60 >> $ps << EOF
14.30 57.70 Jönköping
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
14.16 57.78 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,white+jLB >> $ps << EOF
17.0 59.67 Uppsala
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
17.64 59.86 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,white+jLB >> $ps << EOF
15.0 58.22 Linköping
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
15.63 58.42 0.20c
EOF

# insert map
# Countries codes: ISO 3166-1 alpha-2. Continent codes AF (Africa), AN (Antarctica), AS (Asia), EU (Europe), OC (Oceania), NA (North America), or SA (South America). -EEU+ggrey
gmt psbasemap -R -J -O -K -DjTL+w3.5c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thinnest,grey -Rg -JG16/62/$w -Da -Glightgoldenrod1 -A5000 -Bga -Wfaint -ESE+gred -Sdodgerblue -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx4.5/-3.1+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.2c -Y19.2c -N -O \
    -F+f10p,0,black+jLB >> $ps << EOF
0.0 9.0 Digital elevation data: GEBCO grid, 15 arc sec (ca. 450 m) resolution
EOF

# Convert to image file using GhostScript
gmt psconvert Topo_SE.ps -A0.5c -E720 -Tj -Z
