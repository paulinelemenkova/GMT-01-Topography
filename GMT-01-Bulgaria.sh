#!/bin/sh
# Purpose: shaded relief grid raster map from the ETOPO1 from 1 arc minute global data set (here: Bulgaria)
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
    FONT_LABEL=7p,Helvetica,dimgray \
# Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults

# Extract a subset of ETOPO1m for the Iceland area
#gmt grdcut ETOPO1_Ice_g_gmt4.grd -R22.0/29.0/41.0/44.5 -Gbg_relief.nc
#gmt grdcut GEBCO_2019.nc -R22.0/29.0/41.0/44.5 -Gbg_relief.nc
gdalinfo -stats bg_relief.nc
# Minimum=-2090.000, Maximum=2656.000

# Make color palette
#gmt makecpt -Ctopo.cpt -V -T-1870/2649 > myocean.cpt
#gmt makecpt -Cworld.cpt -V -T-1870/2649 > myocean.cpt
#gmt makecpt -Cgeo.cpt -V -T-1870/2649 > myocean.cpt
#gmt makecpt -Crelief.cpt -V -T-1870/2649 > myocean.cpt
gmt makecpt -Cgeo.cpt -V -T-2090/2656 > myocean.cpt

ps=TopoBG.ps
# Make raster image
gmt grdimage bg_relief.nc -Cmyocean.cpt -R22.0/29.0/41.0/44.5 -JM6.5i -I+a15+ne0.75 -Xc -K > $ps
    
# Add shorelines
gmt grdcontour bg_relief.nc -R -J -C1000 -W0.1p -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P \
    -Ia/thinner,blue -Na -N1/thick,red -W0.1p -Df -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=wESN \
    --FONT_TITLE=12p,Helvetica,black \
    --MAP_TITLE_OFFSET=1.0c \
    --FONT_ANNOT_PRIMARY=7p,Helvetica,black \
    --FONT_LABEL=7p,Helvetica,black \
    -Bpxg2f0.5a1 -Bpyg2f0.5a1 -Bsxg2 -Bsyg1 \
    -B+t"Topographic map of Bulgaria with its global location (insert map)" -O -K >> $ps

# Add legend
gmt psscale -Dg21.2/41.0+w11.0c/0.15i+v+o0.3/0i+ml+e -R -J -Cmyocean.cpt \
    --FONT_LABEL=7p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=7p,Helvetica,black \
    --FONT_TITLE=6p,Helvetica,black \
    -Bg500f50a500+l"Colors for global bathymetry/topography relief: geo [R=-2090/2656, H=0, C=HSV]" \
    -I0.2 -By+lm -O -K >> $ps
    
# Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=9p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Tdx0.8c/0.4c+w0.3i+f2+l+o0.15i \
    -Lx14.5c/-1.2c+c50+w150k+l"Mercator projection. Scale (km)"+f \
    -UBL/-15p/-38p -O -K >> $ps

# City
gmt pstext -R -J -N -O -K \
-F+f10p,Helvetica,black+jLB -Gwhite@30 >> $ps << EOF
23.0 42.1 Sofia
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
23.0 42.0 0.2c
EOF
    
# insert map
# Countries codes: ISO 3166-1 alpha-2. Continent codes AF (Africa), AN (Antarctica), AS (Asia), EU (Europe), OC (Oceania), NA (North America), or SA (South America). -EEU+ggrey
#gmt psbasemap -R -J -O -K -DjTR+w1.5i+o0.15i/0.1i+stmp -F+gwhite+p1p+c0.1c+s >> $ps
gmt psbasemap -R -J -O -K -DjTR+w2.5c+o-0.2c/-0.2c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thin,grey -Rg -JG25/42N/$w -Da -Gpeachpuff -A5000 -Bg -Wfaint -EBG+gred -Slightskyblue1 -O -K -X$x0 -Y$y0 >> $ps
#gmt pscoast -Rg -JG12/5N/$w -Da -Gbrown -A5000 -Bg -Wfaint -ECM+gbisque -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx6.5/-1.9+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y6.1c -N -O \
    -F+f10p,Helvetica,black+jLB >> $ps << EOF
3.4 9.0 Digital elevation data: SRTM, 15 arc sec resolution grid
EOF

# Convert to image file using GhostScript
gmt psconvert TopoBG.ps -A0.5c -E720 -Tj -Z
