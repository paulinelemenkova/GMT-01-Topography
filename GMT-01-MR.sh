#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: Mali)
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert

exec bash

# Extract a subset of ETOPO1m for the study area
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R-18/-4/14/28 -Gmr1_relief.nc
gmt grdcut GEBCO_2023.nc -R-18/-4/14/28 -Gmr_relief.nc
gmt grdinfo -M mr1_relief.nc
# Topography: Minimum=-3797, Maximum=1816

# Make color palette
gmt makecpt -Cgeo -V -T-3797/1816 > pauline.cpt
# elevation etopo1 world elevation dem1 dem2 dem3 globe geo srtm turbo terra earth

#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R-18/-4/14/28 -JM6.5i -Dh -M -EMR > Mauritania.txt
#####################################################################

ps=Topo_MR.ps
# Make background transparent image
gmt grdimage mr1_relief.nc -Cpauline.cpt -R-18/-4/14/28 -JM6.5i -I+a15+ne0.75 -t40 -Xc -P -K > $ps
.5i
# Add isolines
gmt grdcontour mr1_relief.nc -R -J -C250 -A250+f7p,26,darkbrown -Wthinner,darkbrown -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps
    
#------------------------->
# CLIPPING
# 1. Start: clip the map by mask to only include country
gmt psclip -R-18/-4/14/28 -JM6.5i Mauritania.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage mr1_relief.nc -Cpauline.cpt -R-18/-4/14/28 -JM6.5i -I+a15+ne0.75 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour mr1_relief.nc -R -J -C250 -A250+f7p,26,darkbrown -Wthinnest,darkbrown -O -K >> $ps
# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps
# Add lakes
gmt pscoast -R -J -Ia/thinner,blue -Na -Sroyalblue1 -W2/thin,blue,0.1p -Df -O -K >> $ps
# 3: Undo the clipping
gmt psclip -C -O -K >> $ps
#-------------------------<
    
# Add color legend -R-18/-4/14/28
gmt psscale -Dg-18/13+w16.0c/0.15i+h+o0.3/0i+ml+e -R -J -Cpauline.cpt \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --FONT_TITLE=7p,0,black \
    -Bg500f100a500+l"Colormap: 'geo' Colors for global topography relief [R=-3797/1816, H, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=WEsN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    --MAP_FRAME_PEN=dimgray \
    --MAP_FRAME_WIDTH=0.1c \
    --MAP_TITLE_OFFSET=0.7c \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --FONT_LABEL=8p,25,black \
    --FONT_TITLE=13p,0,black \
        -Bpxg4f1a2 -Bpyg4f2a2 -Bsxg2 -Bsyg2 \
    -B+t"Topographic map of Mauritania" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=9p,0,black \
    --FONT_ANNOT_PRIMARY=9p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx14.0c/-2.4c+c10+w500k+l"Mercator projection. Scale (km)"+f \
    -UBL/0p/-70p -O -K >> $ps

# Study area
# Scene Center Lat DMS     18°47'15.29"N
# Scene Center Long DMS     15°42'03.89"W
# Rotated rectangle. kwargs: coords, direction degrees, x and y-dimension
gmt psxy -R -J -Sj-13/2.2/2.2 -W1.5p,yellow1 -O -K << EOF >> $ps
-15.70 18.78
EOF

# Texts
#
# countries
gmt pstext -R -J -N -O -K \
-F+f18p,19,white+jLB >> $ps << EOF
-14.0 19.8 M  A  U  R  I  T  A  N  I  A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,19,darkslategray+jLB+a60 >> $ps << EOF
-15.0 22.40 W E S T E R N   S A H A R A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,19,darkslategray+jLB+a90 >> $ps << EOF
-5.0 17.85 M  A  L  I
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,19,darkslategray+jLB >> $ps << EOF
-9.0 14.55 M  A  L  I
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,19,darkslategray+jLB >> $ps << EOF
-7.00 27.05 A L G E R I A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,19,darkslategray+jLB >> $ps << EOF
-15.90 14.80 S E N E G A L
EOF
#
gmt pstext -R -J -N -O -K \
-F+f12p,20,salmon4+jLB >> $ps << EOF
-9.8 17.3 Aoukar
-9.8 16.8 Depression
EOF
#
# cities
gmt pstext -R -J -N -O -K \
-F+f12p,0,mintcream+jLB -Gsaddlebrown@80 >> $ps << EOF
-12.46 23.03 Zouérat
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-12.46 22.73 0.25c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,0,mintcream+jLB -Gsaddlebrown@80 >> $ps << EOF
-11.40 16.63 Kiffa
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-11.40 16.53 0.25c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,0,mintcream+jLB -Gsaddlebrown@80 >> $ps << EOF
-16.83 20.93 Nouadhibou
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-17.03 20.93 0.25c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,0,mintcream+jLB -Gsaddlebrown@80 >> $ps << EOF
-16.21 16.65 Rosso
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-15.81 16.52 0.25c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,0,mintcream+jLB -Gsaddlebrown@80 >> $ps << EOF
-11.18 15.65 El Aioun
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-11.18 15.55 0.25c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,0,mintcream+jLB >> $ps << EOF
-15.83 18.09 Nouakchott
EOF
gmt psxy -R -J -Ss -W0.5p -Gred -O -K << EOF >> $ps
-15.97 18.09 0.35c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,0,mintcream+jLB -Gsaddlebrown@80 >> $ps << EOF
-13.05 20.22 Atar
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-13.05 20.52 0.25c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,0,mintcream+jLB >> $ps << EOF
-13.51 16.25 Kaédi
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-13.51 16.15 0.25c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,0,mintcream+jLB -Gpalegreen3@80 >> $ps << EOF
-12.68 15.26 Sélibaby
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-12.18 15.16 0.25c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,0,mintcream+jLB -Gsaddlebrown@80 >> $ps << EOF
-7.25 16.72 Néma
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-7.25 16.62 0.25c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,0,mintcream+jLB -Gsaddlebrown@80 >> $ps << EOF
-11.52 25.12 Bir Moghrein
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-11.62 25.22 0.25c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,0,mintcream+jLB -Gsaddlebrown@80 >> $ps << EOF
-9.55 25.70 Ain Ben Tili
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-9.55 25.99 0.25c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,0,mintcream+jLB -Gsaddlebrown@80 >> $ps << EOF
-7.28 25.37 Chegga
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-5.78 25.37 0.25c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,2,mediumblue+jLB >> $ps << EOF
-15.81 16.25 Senegal
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,2,mediumblue+jLB >> $ps << EOF
-17.5 20.4 Bay of
-17.5 20.1 Arguin
EOF
#
gmt pstext -R -J -N -O -K \
-F+f14p,20,white+jLB >> $ps << EOF
-11.95 24.2 S      A      H      A      R      A
EOF
gmt pstext -R -J -N -O -K \
-F+f14p,20,white+jLB >> $ps << EOF
-14.4 17.7 S       A       H       E       L
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,19,linen+jLB >> $ps << EOF
-13.1 21.10 Adrar
-13.1 20.70 Plateau
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,21,darkred+jLB+a40 >> $ps << EOF
-14.6 19.9 Akchar Desert
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,2,floralwhite+jLB >> $ps << EOF
-11.25 21.11 Richat Structure
-11.25 20.86 (Eye of the Sahara)
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,2,floralwhite+jLB >> $ps << EOF
-12.45 22.30 Mt. Kediet
-12.45 22.10 ej Jill
EOF
gmt psxy -R -J -St -W0.5p -Gred -O -K << EOF >> $ps
-12.57 22.50 0.35c
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,19,floralwhite+jLB >> $ps << EOF
-6.4 20.4 El Djouf
-6.4 20.2 Desert
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,21,floralwhite+jLB >> $ps << EOF
-16.3 20.6 Banc d'Arguin
-16.2 20.3 National
-16.2 20.0 Park
EOF
# insert map
# Countries codes: ISO 3166-1 alpha-2. Continent codes AF (Africa), AN (Antarctica), AS (Asia), EU (Europe), OC (Oceania), NA (North America), or SA (South America). -EEU+ggrey
gmt psbasemap -R -J -O -K -DjTL+w3.5c+o-0.2c/-0.2c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thin,grey -Rg -JG-1.0/8.0N/$w -Da -Glightgoldenrod1 -A5000 -Bga -Wfaint -EMR+gred -Sdodgerblue -O -K -X$x0 -Y$y0 >> $ps
#gmt pscoast -Rg -JG12/5N/$w -Da -Gbrown -A5000 -Bg -Wfaint -ECM+gbisque -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx7.0/-3.1+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y11.4c -N -O \
    -F+f10p,0,black+jLB >> $ps << EOF
2.5 10.4 Digital elevation data: SRTM/GEBCO, 15 arc sec resolution grid
EOF

# Convert to image file using GhostScript
gmt psconvert Topo_MR.ps -A0.5c -E720 -Tj -Z
