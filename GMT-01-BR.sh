#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO dataset (here: Brazil)
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

chsh -s /bin/bash

chsh -s /bin/zsh

#gmt grdcut GEBCO_2019.nc -R285/328/-35/6 -Gbr_relief.nc
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R285/328/-35/6 -Gbr_relief.nc

gdalinfo br_relief.nc -stats
# Minimum=-6519.716, Maximum=3171.734, Mean=-3429.910, StdDev=1855.667

#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R285/328/-35/6 -Dh -M -EBR > br.txt
#####################################################################

# Make color palette
# makecpt --help
gmt makecpt -Cgeo.cpt -V -T-6520/3172 > pauline.cpt

# Generate a file
ps=Topography_BR.ps
# Make background transparent image
gmt grdimage br_relief.nc -Cpauline.cpt -R285/328/-35/6 -JM6i -P -I+a15+ne0.75 -t50 -Xc -K > $ps
    
# Add isolines
gmt grdcontour br_relief1.nc -R -J -C1000 -W0.1p -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P \
    -Ia/thinner,blue -Na -N1/thick,deeppink1 -W0.1p -Df -O -K >> $ps
    
#####################################################################
# CLIPPING
# 1. Start: clip the map by mask to only include country

# 360-32
gmt psclip -R285/328/-35/6 -JM6.0i br.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage br_relief.nc -Cpauline.cpt -R285/328/-35/6 -JM6.0i -I+a15+ne0.75 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour br_relief.nc -R -J -C1000 -Wthinnest,darkbrown -O -K >> $ps
# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thick,deeppink1 -W0.1p -Df -O -K >> $ps

# 3: Undo the clipping
gmt psclip -C -O -K >> $ps
#####################################################################

# Add color barlegend
gmt psscale -Dg285/-37.5+w15.2c/0.4c+h+o0.0/0i+ml -R -J -Cpauline.cpt \
    --FONT_LABEL=8p,Helvetica,black \
    --MAP_LABEL_OFFSET=0.1c \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,black \
    -Bg500f50a1000+l"Color scale 'geo': global bathymetry/topography relief [R=-6857/3206, H=0, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=WEsN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    -Bpx4f2a4 -Bpyg4f2a4 -Bsxg4 -Bsyg2 \
    --MAP_TITLE_OFFSET=0.8c \
    --FONT_TITLE=14p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=7p,Helvetica,black \
    -B+t"Topographic map of Brazil" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=10p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=8p,Helvetica,black \
    --MAP_LABEL_OFFSET=0.1c \
    -Lx12.7c/-2.3c+c50+w700k+l"Mercator projection. Scale: km"+f \
    -UBL/-5p/-65p -O -K >> $ps
    
# Texts -R285/328/-35/6
# Cities
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB+a-0 -Gwhite@60 >> $ps << EOF
313.67 -23.85 São Paulo
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
313.37 -23.55 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB+a-0 -Gwhite@60 >> $ps << EOF
317.09 -22.91 Rio de Janeiro
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
316.79 -22.91 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB+a-0 -Gwhite@60 >> $ps << EOF
316.37 -19.91 Belo Horizonte
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
316.07 -19.91 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB+a-0 -Gwhite@60 >> $ps << EOF
325.40 -8.05 Recife
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
325.10 -8.05 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB+a-0 -Gwhite@60 >> $ps << EOF
312.52 -15.79 Brasília
EOF
gmt psxy -R -J -Sc -W0.5p -Gred -O -K << EOF >> $ps
312.12 -15.79 0.25c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB+a-0 -Gwhite@60 >> $ps << EOF
309.07 -30.03 Porto Alegre
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
308.77 -30.03 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB+a-0 -Gwhite@60 >> $ps << EOF
321.83 -12.97 Salvador,
321.83 -13.77 Bahia
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
321.53 -12.97 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB+a-0 -Gwhite@60 >> $ps << EOF
321.77 -3.73 Fortaleza
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
321.47 -3.73 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB+a-0 -Gwhite@60 >> $ps << EOF
311.05 -25.42 Curitiba
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
310.75 -25.42 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB+a-0 -Gwhite@60 >> $ps << EOF
311.05 -17.0 Goiânia
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
310.75 -16.67 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB+a-0 -Gwhite@60 >> $ps << EOF
311.8 -1.45 Belém
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
311.5 -1.45 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB+a-0 -Gwhite@60 >> $ps << EOF
300.18 -4.1 Manaus
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
299.98 -3.1 0.20c
EOF

# Water
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,26,blue1+jLB >> $ps << EOF
285.5 -22.0 Pacific
285.5 -24.0 Ocean
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,26,blue1+jLB >> $ps << EOF
320 -28.0 Atlantic
320 -30.0 Ocean
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,26,blue1+jLB >> $ps << EOF
314 4.0 Atlantic
314 2.0 Ocean
EOF

# Texts -R285/328/-35/6
# countries
gmt pstext -R -J -N -O -K \
-F+jTL+f13p,25,black+jLB -Gwhite@60 >> $ps << EOF
300.20 -10.1 B     R     A     Z     I    L
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,25,black+jLB -Gwhite@60 >> $ps << EOF
292.50 -18.1 B O L I V I A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,25,black+jLB -Gwhite@60 >> $ps << EOF
292.30 -30.1 A R G E N T I N A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,25,black+jLB+a-45 -Gwhite@60 >> $ps << EOF
300.0 -22.0 PARAGUAY
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,25,black+jLB -Gwhite@60 >> $ps << EOF
302.0 -33.0 URUGUAY
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,25,black+jLB -Gwhite@60 >> $ps << EOF
286 -13.0 P E R U
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,25,black+jLB -Gwhite@60 >> $ps << EOF
285 3.0 C O L O M B I A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,25,black+jLB -Gwhite@60 >> $ps << EOF
292.5 5.0 VENEZUELA
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,25,black+jLB+a-75 -Gwhite@60 >> $ps << EOF
300.5 5.6 GUYANA
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f7p,25,black+jLB+a-75 -Gwhite@60 >> $ps << EOF
303 5.8 SURINAME
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,25,black+jLB -Gwhite@60 >> $ps << EOF
306 5.0 FRENCH
306 4.0 GUIANA
EOF

# insert map
# Countries codes: ISO 3166-1 alpha-2. Continent codes AF (Africa), AN (Antarctica), AS (Asia), EU (Europe), OC (Oceania), NA (North America), or SA (South America). -EEU+ggrey
gmt psbasemap -R -J -O -K -DjTR+w3.0c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thin,grey -Rg -JG300/12S/$w -Da -Gbrown -A5000 -Bg -Wfaint -ESA+gpeachpuff -EBR+ggoldenrod1 -Sslategray2 -O -K -X$x0 -Y$y0 >> $ps
#gmt pscoast -Rg -JG12/5N/$w -Da -Gbrown -A5000 -Bg -Wfaint -ECM+gbisque -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx6.2/-3.0+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y6.9c -N -O \
    -F+f12p,Helvetica,black+jLB >> $ps << EOF
1.5 13.6 SRTM/GEBCO 15 arc sec resolution global terrain model grid
EOF

# Convert to image file using GhostScript
gmt psconvert Topography_BR.ps -A1.0c -E720 -Tj -Z
