#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: Mali)
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert

exec bash

# Extract a subset of ETOPO1m for the study area
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R-19/-11/12/17 -Gsn1_relief.nc
gmt grdcut GEBCO_2019.nc -R-19/-11/12/17 -Gsn_relief.nc
gdalinfo -stats sn1_relief.nc
# Topography: Minimum=-3395.000, Maximum=1434.000, Mean=-118.696, StdDev=610.604

# Make color palette
# gmt makecpt -Cgeo -V -T-3395/1434 > pauline.cpt
# gmt makecpt -Cturbo -V -T-3395/1434 > pauline.cpt
# gmt makecpt -Cterra -V -T-3395/1434 > pauline.cpt
# gmt makecpt -Cearth -V -T-3395/1434 > pauline.cpt
# gmt makecpt -Cdem1 -V -T-3395/1434 > pauline.cpt
 gmt makecpt -Cgeo -V -T-3395/1434 > pauline.cpt
# elevation etopo1 world elevation dem1 dem2 dem3 globe geo srtm turbo terra earth

#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R-19/-11/12/17 -JM6.5i -Dh -M -ESN > Senegal.txt
#####################################################################

ps=Topo_SN.ps
# Make background transparent image
gmt grdimage sn_relief.nc -Cpauline.cpt -R-19/-11/12/17 -JM6.5i -I+a15+ne0.75 -t40 -Xc -P -K > $ps
.5i
# Add isolines
gmt grdcontour sn1_relief.nc -R -J -C250 -A250+f7p,26,darkbrown -Wthinner,darkbrown -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps
    
#------------------------->
# CLIPPING
# 1. Start: clip the map by mask to only include country
gmt psclip -R-19/-11/12/17 -JM6.5i Senegal.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage sn_relief.nc -Cpauline.cpt -R-19/-11/12/17 -JM6.5i -I+a15+ne0.75 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour sn1_relief.nc -R -J -C250 -A250+f7p,26,darkbrown -Wthinnest,darkbrown -O -K >> $ps
# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps

# 3: Undo the clipping
gmt psclip -C -O -K >> $ps
#-------------------------<
    
# Add color legend
gmt psscale -Dg-19/11.5+w16.5c/0.15i+h+o0.3/0i+ml+e -R -J -Cpauline.cpt \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_TITLE=6p,0,black \
    -Bg1000f100a500+l"Colormap: 'geo' Colors for global topography relief [R=-3395/1434, H, C=RGB]" \
    -I0.2 -By+l"m" -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=WEsN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    --MAP_FRAME_PEN=dimgray \
    --MAP_FRAME_WIDTH=0.1c \
    --MAP_TITLE_OFFSET=0.7c \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --FONT_LABEL=8p,25,black \
    --FONT_TITLE=12p,0,black \
        -Bpxg4f1a2 -Bpyg4f2a1 -Bsxg2 -Bsyg1 \
    -B+t"Topographic map of Senegal" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=9p,0,black \
    --FONT_ANNOT_PRIMARY=9p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx14.0c/-2.5c+c10+w200k+l"Mercator projection. Scale (km)"+f \
    -UBL/0p/-70p -O -K >> $ps

# Study area
# Rotated rectangle. kwargs: coords, direction degrees, x and y-dimension
gmt psxy -R -J -Sj1c -W1.7p,chartreuse -O -K << EOF >> $ps
-4.5 14.5 -13 1.5 1.5
EOF

# Texts
# countries
gmt pstext -R -J -N -O -K \
-F+f11p,0,gray25+jLB >> $ps << EOF
-13.95 16.5 M A U R I T A N I A
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,gray25+jLB >> $ps << EOF
-16.2 13.40 GAMBIA
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,gray25+jLB >> $ps << EOF
-15.8 12.1 G U I N E A - B I S A U
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,gray25+jLB >> $ps << EOF
-13.7 12.1 G U I N E A
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,0,gray25+jLB >> $ps << EOF
-11.75 14.8 M A L I
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f19p,29,cornsilk+jLB >> $ps << EOF
-15.8 14.2 S   E   N   E   G   A   L
EOF

# insert map
# Countries codes: ISO 3166-1 alpha-2. Continent codes AF (Africa), AN (Antarctica), AS (Asia), EU (Europe), OC (Oceania), NA (North America), or SA (South America). -EEU+ggrey
gmt psbasemap -R -J -O -K -DjTL+w3.2c+o-0.2c/-0.2c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thin,grey -Rg -JG-1.0/8.0N/$w -Da -Glightgoldenrod1 -A5000 -Bga -Wfaint -ESN+gred -Sdodgerblue -O -K -X$x0 -Y$y0 >> $ps
#gmt pscoast -Rg -JG12/5N/$w -Da -Gbrown -A5000 -Bg -Wfaint -ECM+gbisque -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx7.0/-3.1+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y4.4c -N -O \
    -F+f10p,0,black+jLB >> $ps << EOF
2.5 10.4 Digital elevation data: SRTM/GEBCO, 15 arc sec resolution grid
EOF

# Convert to image file using GhostScript
gmt psconvert Topo_SN.ps -A0.5c -E720 -Tj -Z
