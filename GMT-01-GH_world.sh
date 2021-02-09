#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: Ghana)
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
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R-4/2/4/12 -Ggh_relief1.nc
gmt grdcut GEBCO_2019.nc -R-4/2/4/12 -Ggh_relief.nc
gdalinfo -stats gh_relief.nc
#  Minimum=-4696.000, Maximum=915.000, Mean=-206.102, StdDev=1146.375

# Make color palette
gmt makecpt -Cworld.cpt -V -T-4696/915 > pauline.cpt
# elevation etopo1 world dem1 dem2 dem3 globe geo srtm turbo terra earth

#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R-4/2/4/12 -JM5.0i -Dh -M -EGH > Ghana.txt
#gmt pscoast -Dh -M -ELB > Malawi.txt
#####################################################################

ps=Topo_GH.ps
# Make background transparent image
gmt grdimage gh_relief.nc -Cpauline.cpt -R-4/2/4/12 -JM5.0i -I+a15+ne0.75 -t40 -Xc -P -K > $ps
    
# Add isolines
gmt grdcontour gh_relief1.nc -R -J -C1000 -A1000+f7p,26,darkbrown -Wthinner,darkbrown -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thick,dimgray -W0.1p -Df -O -K >> $ps
    
#####################################################################
# CLIPPING
# 1. Start: clip the map by mask to only include country
#gmt psclip -JM -R Malawi.txt -O -K >> $ps

gmt psclip -R-4/2/4/12 -JM5.0i Ghana.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage gh_relief.nc -Cpauline.cpt -R-4/2/4/12 -JM5.0i -I+a15+ne0.75 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour gh_relief.nc -R -J -C500 -Wthinnest,darkbrown -O -K >> $ps
# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thickest,tomato -W0.1p -Df -O -K >> $ps
#gmt pscoast -R -J \
    -Ia/thinner,blue -Na -W0.1p -Df -O -K >> $ps

# 3: Undo the clipping
gmt psclip -C -O -K >> $ps
#####################################################################
    
# Add color legend
gmt psscale -Dg-4/3.4+w12.0c/0.15i+h+o0.3/0i+ml+e -R -J -Cpauline.cpt \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_TITLE=6p,0,black \
    -Bg500f50a500+l"Colormap: 'world' Colors for global bathymetry/topography relief [R=-4696/915, H=0, C=HSV]" \
    -I0.2 -By+lm -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=WEsN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    --MAP_TITLE_OFFSET=0.8c \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --FONT_LABEL=8p,25,black \
    --FONT_TITLE=16p,13,black \
        -Bpxg2f1a0.5 -Bpyg2f1a1 -Bsxg2 -Bsyg1 \
    -B+t"Topographic map of Ghana" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx11.0c/-2.5c+c10+w100k+l"Mercator projection. Scale (km)"+f \
    -UBL/0p/-70p -O -K >> $ps

# Texts
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,slateblue1+jLB -Gwhite@70 >> $ps << EOF
0.5 4.6 Gulf of Guinea
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,slateblue1+jLB -Gwhite@70 >> $ps << EOF
-3.5 4.3 Atlantic Ocean
EOF
# COUNTRIES
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,25,darkred+jLB >> $ps << EOF
-1.8 8.2 G   H   A   N   A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,25,black+jLB >> $ps << EOF
0.7 8.5 T O G O
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,25,darkred+jLB >> $ps << EOF
-3.6 8.9 IVORY
-3.6 8.5 COAST
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,25,black+jLB >> $ps << EOF
1.4 9.8 BENIN
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,25,darkred+jLB >> $ps << EOF
-3.5 11.5 B  U  R  K  I  N  A      F  A  S  O
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,26,blue2+jLB+a-277 >> $ps << EOF
0.2 6.7 Lake Volta
EOF
# Cities
gmt pstext -R -J -N -O -K \
-F+f11p,13,black+jLB >> $ps << EOF
-0.2 5.4 Accra
EOF
gmt psxy -R -J -Ss -W0.5p -Gred -O -K << EOF >> $ps
-0.1 5.6 0.30c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,white+jLB >> $ps << EOF
-1.1 10.6 Bolgatanga
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-0.5 10.5 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,black+jLB >> $ps << EOF
-1.0 5.1 Cape Coast
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-1.1 5.2 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,black+jLB >> $ps << EOF
-1.15 5.0 Elmina
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-1.2 5.1 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,white+jLB >> $ps << EOF
-0.1 6.0 Koforidua
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-0.2 6.0 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,white+jLB >> $ps << EOF
-1.3 6.4 Kumasi
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-1.4 6.4 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,white+jLB >> $ps << EOF
-1.3 6.1 Obuasi
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-1.4 6.1 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,black+jLB >> $ps << EOF
-1.8 4.8 Sekondi-
-1.8 4.6 Takoradi
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-1.5 5.0 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,white+jLB >> $ps << EOF
-1.0 9.3 Tamale
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
-0.5 9.2 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,white+jLB >> $ps << EOF
0.0 9.3 Yendi
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
0.0 9.3 0.20c
EOF

# insert map
# Countries codes: ISO 3166-1 alpha-2. Continent codes AF (Africa), AN (Antarctica), AS (Asia), EU (Europe), OC (Oceania), NA (North America), or SA (South America). -EEU+ggrey
gmt psbasemap -R -J -O -K -DjTR+w3.2c+o-0.2c/-0.2c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thin,grey -Rg -JG-1.0/8.0N/$w -Da -Gkhaki1 -A5000 -Bga -Wfaint -EGH+gred -Scadetblue2 -O -K -X$x0 -Y$y0 >> $ps
#gmt pscoast -Rg -JG12/5N/$w -Da -Gbrown -A5000 -Bg -Wfaint -ECM+gbisque -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx5.0/-3.1+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y11.0c -N -O \
    -F+f10p,0,black+jLB >> $ps << EOF
0.5 10.3 Digital elevation data: SRTM/GEBCO, 15 arc sec resolution grid
EOF

# Convert to image file using GhostScript
gmt psconvert Topo_GH.ps -A0.5c -E720 -Tj -Z
