#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: Benin)
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

exec bash

# Extract a subset of ETOPO1m for the study area
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R0/5/5.5/12.5 -Gbj1_relief.nc
gmt grdcut GEBCO_2023.nc -R0/5/5.5/12.5 -Gbj_relief.nc
gmt grdinfo -M bj_relief.nc
# gdalinfo -stats bj_relief.nc
# Topography: actual_range={-3746/1398}

# Make color palette
gmt makecpt -Cgeo -V -T-3779/949 > pauline.cpt
# elevation etopo1 world elevation dem1 dem2 dem3 globe geo srtm turbo terra earth

#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R0/5/5.5/12.5 -JM5.5i -Dh -M -EBJ > Benin.txt
#####################################################################

ps=Topo_BJ.ps
# Make background transparent image
gmt grdimage bj1_relief.nc -Cpauline.cpt -R0/5/5.5/12.5 -JM5.5i -I+a15+ne0.75 -t40 -Xc -P -K > $ps
    
# Add isolines
gmt grdcontour bj_relief.nc -R -J -C1000 -A1000+f7p,26,darkbrown -Wthinner,darkbrown -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thick,dimgray -W0.1p -Df -O -K >> $ps
    
#####################################################################
# CLIPPING
# 1. Start: clip the map by mask to only include country

gmt psclip -R0/5/5.5/12.5 -JM5.5i Benin.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage bj1_relief.nc -Cpauline.cpt -R0/5/5.5/12.5 -JM5.5i -I+a15+ne0.75 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour bj1_relief.nc -R -J -C500 -Wthinnest,darkbrown -O -K >> $ps
# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps
#gmt pscoast -R -J \
    -Ia/thinner,blue -Na -W0.1p -Df -O -K >> $ps

# 3: Undo the clipping
gmt psclip -C -O -K >> $ps
#####################################################################
    
# Add color legend
gmt psscale -Dg-0.8/5.5+w19.0c/0.15i+v+o0.3/0i+ml+e -R -J -Cpauline.cpt \
    --FONT_LABEL=10p,0,black \
    --FONT_ANNOT_PRIMARY=10p,0,black \
    --FONT_TITLE=10p,0,black \
    -Bg500f50a500+l"Colormap: 'geo' Colors for global bathymetry/topography relief [R=-3746/1398, H, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=wESN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    --MAP_TITLE_OFFSET=0.7c \
    --FONT_ANNOT_PRIMARY=9p,0,black \
    --FONT_LABEL=10p,25,black \
    --FONT_TITLE=13p,0,black \
        -Bpxg2f1a1 -Bpyg2f1a1 -Bsxg2 -Bsyg1 \
    -B+t"Carte topographique du Bénin" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx11.7c/-2.0c+c10+w200k+l"Mercator projection. Scale (km)"+f \
    -UBL/0p/-60p -O -K >> $ps

# Texts
# Cities -R0/5/5.5/12.5
gmt pstext -R -J -N -O -K \
-F+f15p,0,black+jLB -Gwhite@50 >> $ps << EOF
2.46 6.16 Cotonou
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
2.43 6.36 0.25c
EOF
gmt pstext -R -J -N -O -K \
-F+f15p,0,black+jLB -Gwhite@50 >> $ps << EOF
1.70 6.55 Porto-Novo
EOF
gmt psxy -R -J -Ss -W0.5p -Gred -O -K << EOF >> $ps
2.61 6.49 0.35c
EOF
gmt pstext -R -J -N -O -K \
-F+f15p,0,white+jLB >> $ps << EOF
2.47 9.45 Parakou
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
2.62 9.35 0.25c
EOF
gmt pstext -R -J -N -O -K \
-F+f15p,0,black+jLB -Gwhite@50 >> $ps << EOF
1.50 6.17 Godomey
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
2.35 6.37 0.25c
EOF
gmt pstext -R -J -N -O -K \
-F+f15p,0,white+jLB >> $ps << EOF
1.56 9.78 Djougou
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
1.66 9.7 0.25c
EOF
gmt pstext -R -J -N -O -K \
-F+f15p,0,black+jLB >> $ps << EOF
1.87 7.30 Bohicon
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
2.06 7.2 0.25c
EOF
gmt pstext -R -J -N -O -K \
-F+f15p,0,white+jLB >> $ps << EOF
3.11 10.0 Nikki
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
3.21 9.93 0.25c
EOF


# insert map
# Countries codes: ISO 3166-1 alpha-2. Continent codes AF (Africa), AN (Antarctica), AS (Asia), EU (Europe), OC (Oceania), NA (North America), or SA (South America). -EEU+ggrey
gmt psbasemap -R -J -O -K -DjBR+w4.5c+o-0.2c/-0.2c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thin,grey -Rg -JG-1.0/8.0N/$w -Da -Glightgoldenrod1 -A5000 -Bga -Wfaint -EBJ+gred -Sdodgerblue -O -K -X$x0 -Y$y0 >> $ps
#gmt pscoast -Rg -JG12/5N/$w -Da -Gbrown -A5000 -Bg -Wfaint -ECM+gbisque -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx6.0/-2.5+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y14.0c -N -O \
    -F+f12p,0,black+jLB >> $ps << EOF
0.5 10.0 Digital elevation data: SRTM/GEBCO, 15 arc sec resolution grid
EOF

# Convert to image file using GhostScript
gmt psconvert Topo_BJ.ps -A0.5c -E720 -Tj -Z
