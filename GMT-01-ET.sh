#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: Ethiopia)
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
#gmt grdcut ETOPO1_Ice_g_gmt4.grd -R33/48/3/15 -Get_relief.nc
gmt grdcut GEBCO_2019.nc -R33/48/3/15 -Get_relief.nc
gdalinfo -stats et_relief.nc
# Minimum=-3558.005, Maximum=4455.414, Mean=814.823


# Make color palette
#gmt makecpt -Cturbo.cpt -V -T-3481/4326 > myocean.cpt
gmt makecpt -Cturbo.cpt -V -T-3559/4456 > myocean.cpt
# elevation etopo1 world elevation dem1 dem2 dem3

#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R33/48/3/15 -JM6.5i -Dh -M -EET > Ethiopia.txt
#gmt pscoast -Dh -M -ELB > Ethiopia.txt
#####################################################################

ps=Topo_ET.ps
# Make background transparent image
gmt grdimage et_relief.nc -Cmyocean.cpt -R33/48/3/15 -JM6.5i -I+a15+ne0.75 -t60 -Xc -P -K > $ps
    
# Add isolines
#gmt grdcontour et_relief.nc -R -J -C500 -A1000+f7p,26,darkbrown -Wthinner,darkbrown -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P \
    -Ia/thinner,blue -Na -Wthinner -Df -O -K >> $ps
    
#####################################################################
# CLIPPING
# 1. Start: clip the map by mask to only include country
#gmt psclip -JM -R Ethiopia.txt -O -K >> $ps

gmt psclip -R33/48/3/15 -JM6.5i Ethiopia.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage et_relief.nc -Cmyocean.cpt -R33/48/3/15 -JM6.5i -I+a15+ne0.75 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour et_relief.nc -R -J -C500 -Wthinnest,darkbrown -O -K >> $ps
# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thickest,red -W0.1p -Df -O -K >> $ps
#gmt pscoast -R -J \
    -Ia/thinner,blue -Na -W0.1p -Df -O -K >> $ps

# 3: Undo the clipping
gmt psclip -C -O -K >> $ps
#####################################################################
    
# Add color legend
gmt psscale -Dg31.5/3+w13.3c/0.15i+v+o0.0/0i+ml -R -J -Cmyocean.cpt \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_TITLE=6p,0,black \
    -Bg500f50a500+l"Colormap: 'turbo' Google's Improved Rainbow CPT [R=-3481/4326, H=0, C=HSV]" \
    -I0.2 -By+lm -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=wESN \
    --FORMAT_GEO_MAP=ddd:mm:ss \
    --MAP_TITLE_OFFSET=0.8c \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_LABEL=7p,25,black \
    --FONT_TITLE=16p,13,black \
    -Bpxg50f1a2 -Bpyg20f2a2 -Bsxg50 -Bsyg20 \
    -B+t"Topographic map of Ethiopia" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Tdx15.0c/11.5c+w0.5i+f2+l+o0.15i \
    -Lx14.5c/-1.2c+c10+w300k+l"Mercator projection. Scale (km)"+f \
    -UBL/-10p/-40p -O -K >> $ps

# Texts
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,0,royalblue4+jLB >> $ps << EOF
41.5 14.3 Red Sea
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,0,royalblue4+jLB+a-345 -Gwhite@50 >> $ps << EOF
45.5 11.8 Gulf of Aden
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,26,blue2+jLB+a-60 -Gwhite@70 >> $ps << EOF
42.9 13.4 Bab-el-Mandeb
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,26,blue2+jLB+a-22 -Gwhite@70 >> $ps << EOF
37.35 11.2 Blue Nile
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,26,blue2+jLB -Gwhite@70 >> $ps << EOF
37.0 12.1 Lake
37.0 11.8 Tana
EOF

# Nat. Parks
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,26,darkgreen+jLB -Gwhite@50 >> $ps << EOF
37.1 13.8 Semien Mts
37.1 13.5 Nat. Park
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,26,darkgreen+jLB -Gwhite@40 >> $ps << EOF
36.1 5.4 Mago
36.1 5.1 Nat. Park
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,26,darkgreen+jLB -Gwhite@40 >> $ps << EOF
35.5 6.1 Omo
35.5 5.8 Nat. Park
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,26,darkgreen+jLB -Gwhite@40 >> $ps << EOF
34.0 7.5 Gambela
34.1 7.2 Nat. Park
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,26,darkgreen+jLB -Gwhite@50 >> $ps << EOF
40.8 10.1 Yangudi Rassa
40.8 9.8 Nat. Park
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,26,darkgreen+jLB -Gwhite@40 >> $ps << EOF
40.0 8.5 Awash
40.0 8.2 Nat. Park
EOF

# COUNTRIES
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,25,firebrick3+jLB -Gwhite@30 >> $ps << EOF
33.5 11.5 SUDAN
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,25,firebrick3+jLB+a-330 -Gwhite@50 >> $ps << EOF
45.0 3.6 S O M A L I A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,25,firebrick3+jLB -Gwhite@40 >> $ps << EOF
35.0 3.8 K E N Y A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,25,firebrick3+jLB -Gwhite@30 >> $ps << EOF
44.8 14.5 YEMEN
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,25,firebrick3+jLB+a-50 -Gwhite@30 >> $ps << EOF
41.0 14.3 ERITREA
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f7p,25,firebrick3+jLB+a-300 -Gwhite@30 >> $ps << EOF
42.1 11.1 DJIBOUTI
EOF

gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,blue2+jLB+a-305 -Gwhite@70 >> $ps << EOF
37.9 6.5 Great Rift
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,blue2+jLB+a-320 -Gwhite@70 >> $ps << EOF
39.0 8.0 Valley
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,26,saddlebrown+jLB+a-330 -Gwhite@70 >> $ps << EOF
45.0 7.5 Ogaden
45.0 7.2 Desert
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,26,blue2+jLB+a-45 -Gwhite@70 >> $ps << EOF
40.5 13.8 Danakil
40.5 13.4 Depression
EOF
gmt pstext -R -J -N -O -K \
-F+f14p,13,white+jLB -Gsaddlebrown@60 >> $ps << EOF
36.5 10.3 Ethiopian
EOF
gmt pstext -R -J -N -O -K \
-F+f14p,13,white+jLB -Gsaddlebrown@60 >> $ps << EOF
36.5 8.3 Highlands
EOF

# Cities
gmt pstext -R -J -N -O -K \
-F+f11p,13,black+jLB -Gwhite@40 >> $ps << EOF
37.4 9.3 Addis Ababa
EOF
gmt psxy -R -J -Ss -W0.5p -Gwhite -O -K << EOF >> $ps
38.4 9.1 0.30c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,black+jLB -Gwhite@40 >> $ps << EOF
40.5 11.6 Semera
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
41.0 11.5 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,13,black+jLB -Gwhite@40 >> $ps << EOF
35.9 11.3 Bahir Dar
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
37.3 11.4 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,black+jLB -Gwhite@40 >> $ps << EOF
34.4 10.1 Assosa
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
34.3 10.0 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,black+jLB+a-353 -Gwhite@40 >> $ps << EOF
41.6 9.3 Dire Dawa
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
41.5 9.3 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,black+jLB -Gwhite@40 >> $ps << EOF
34.4 8.2 Gambela
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
34.3 8.1 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,black+jLB -Gwhite@40 >> $ps << EOF
41.7 8.8 Harar
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
42.0 9.2 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,black+jLB -Gwhite@40 >> $ps << EOF
38.8 7.3 Awasa
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
38.6 7.3 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,black+jLB -Gwhite@40 >> $ps << EOF
42.6 9.1 Jijiga
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
42.5 9.2 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,black+jLB -Gwhite@40 >> $ps << EOF
38.8 13.5 Mekelle
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
39.3 13.3 0.20c
EOF

# insert map
# Countries codes: ISO 3166-1 alpha-2. Continent codes AF (Africa), AN (Antarctica), AS (Asia), EU (Europe), OC (Oceania), NA (North America), or SA (South America). -EEU+ggrey
gmt psbasemap -R -J -O -K -DjTL+w3.2c+o-0.2c/-0.2c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thin,grey -Rg -JG35.0/-6.0N/$w -Da -Glightgoldenrod1 -A5000 -Bga -Wfaint -EET+gred -Sdodgerblue -O -K -X$x0 -Y$y0 >> $ps
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
gmt psconvert Topo_ET.ps -A0.5c -E720 -Tj -Z
