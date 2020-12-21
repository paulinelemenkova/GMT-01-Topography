#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: Pakistan)
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
#gmt grdcut ETOPO1_Ice_g_gmt4.grd -R60.0/80.0/23.5/37.2 -Gpk_relief.nc
gmt grdcut GEBCO_2019.nc -R60.0/80.0/23.5/37.2 -Gpk_relief.nc
gdalinfo -stats pk_relief.nc
# Minimum=-3549.000, Maximum=7966.000

# Make color palette
#gmt makecpt -Ctopo.cpt -V -T-1870/2649 > myocean.cpt
#gmt makecpt -Cworld.cpt -V -T-1870/2649 > myocean.cpt
#gmt makecpt -Cgeo.cpt -V -T-1870/2649 > myocean.cpt
#gmt makecpt -Crelief.cpt -V -T-1870/2649 > myocean.cpt
gmt makecpt -Cgeo.cpt -V -T-3549/7966 > myocean.cpt

ps=TopoPK.ps
# Make raster image
gmt grdimage pk_relief.nc -Cmyocean.cpt -R60.0/80.0/23.5/37.2 -JM6.5i -I+a15+ne0.75 -Xc -K > $ps

# Add legend
gmt psscale -Dg57.3/23.5+w13.2c/0.15i+v+o0.3/0i+ml -R -J -Cmyocean.cpt \
	--FONT_LABEL=7p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=7p,Helvetica,black \
    --FONT_TITLE=6p,Helvetica,black \
	-Bg500f50a500+l"Color scale: geo [R=-3549/7966, H=0, C=HSV]" \
	-I0.2 -By+lm -O -K >> $ps
    
# Add shorelines
gmt grdcontour pk_relief.nc -R -J -C1000 -W0.1p -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P \
    -Ia/thinner,blue -Na -N1/thickest,red -W0.1p -Df -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=wESN \
    --MAP_TITLE_OFFSET=1.0c \
    --FONT_ANNOT_PRIMARY=7p,Helvetica,black \
    --FONT_LABEL=7p,Helvetica,black \
    -Bpxg2f1a2 -Bpyg2f1a2 -Bsxg2 -Bsyg1 \
    -B+t"Topographic map of Pakistan with its global location (insert map)" -O -K >> $ps
    
# Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=7p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Tdx15.0c/0.4c+w0.3i+f2+l+o0.15i \
    -Lx14.5c/-1.3c+c50+w300k+l"Mercator projection. Scale (km)"+f \
    -UBL/-15p/-38p -O -K >> $ps

# Texts
gmt pstext -R -J -N -O -K \
-F+f11p,Times-Roman,black+jLB -Gwhite@30 >> $ps << EOF
67.3 24.6 Karachi
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
67.3 24.4 0.15c
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,Helvetica,black+jLB -Gwhite@40 -Wthinnest >> $ps << EOF
69.0 30.5 P A K I S T A N
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Helvetica,black+jLB -Gwhite@40 -Wthinnest >> $ps << EOF
75.0 27.5 I N D I A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Helvetica,black+jLB -Gwhite@40 -Wthinnest >> $ps << EOF
64.0 33.5 A F G H A N I S T A N
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Helvetica,black+jLB -Gwhite@40 -Wthinnest >> $ps << EOF
60.5 27.5 I R A N
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Helvetica,black+jLB -Gwhite@40 -Wthinnest >> $ps << EOF
77.0 36.5 CHINA
EOF

gmt pstext -R -J -N -O -K \
-F+jTL+f11p,Times−Italic,white+jLB+a-324 >> $ps << EOF
68.7 28.0 Indus River
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,Helvetica,white+jLB >> $ps << EOF
60.6 24.2  A r a b i a n  S e a
EOF
    
# insert map
# Countries codes: ISO 3166-1 alpha-2. Continent codes AF (Africa), AN (Antarctica), AS (Asia), EU (Europe), OC (Oceania), NA (North America), or SA (South America). -EEU+ggrey
#gmt psbasemap -R -J -O -K -DjTR+w1.5i+o0.15i/0.1i+stmp -F+gwhite+p1p+c0.1c+s >> $ps
gmt psbasemap -R -J -O -K -DjTL+w3.2c+o-0.2c/-0.2c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thin,grey -Rg -JG70/30N/$w -Da -Gpeachpuff -A5000 -Bga -Wfaint -EPK+gred -Slightskyblue1 -O -K -X$x0 -Y$y0 >> $ps
#gmt pscoast -Rg -JG12/5N/$w -Da -Gbrown -A5000 -Bg -Wfaint -ECM+gbisque -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx7.0/-2.0+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y8.0c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
3.7 8.9 Digital elevation data: SRTM, 15 arc sec resolution grid
EOF

# Convert to image file using GhostScript
gmt psconvert TopoPK.ps -A0.2c -E720 -Tj -Z
