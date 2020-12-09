#!/bin/sh
# Purpose: shaded relief grid raster map from the ETOPO1 from 1 arc minute global data set (here: Kuril-Kamchatka Trench)
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
#gmt grdcut ETOPO1_Ice_g_gmt4.grd -R24.0/46.0/35.5/42.5 -Gtr_relief.nc
gmt grdcut GEBCO_2019.nc -R24.0/46.0/35.5/42.5 -Gtr_relief.nc
gdalinfo -stats tr_relief.nc
# -4468,4790

# Make color palette
#gmt makecpt -Ctopo.cpt -V -T-1870/2649 > myocean.cpt
#gmt makecpt -Cworld.cpt -V -T-1870/2649 > myocean.cpt
#gmt makecpt -Cgeo.cpt -V -T-1870/2649 > myocean.cpt
#gmt makecpt -Crelief.cpt -V -T-1870/2649 > myocean.cpt
gmt makecpt -Cgeo.cpt -V -T-4468/4790 > myocean.cpt

ps=TopoTR.ps
# Make raster image
#gmt grdimage ice_relief.nc -Cmyocean.cpt -R335/347/63/67 -JM6i -P -I+a15+ne0.75 -Xc -K > $ps
#gmt grdimage ice_relief.nc -Cmyocean.cpt -R335/347/63/67 -JM6i -P -I+a15+ne0.75 -Xc -K > $ps
gmt grdimage tr_relief.nc -Cmyocean.cpt -R24.0/46.0/35.5/42.5 -JM6.5i -I+a15+ne0.75 -Xc -K > $ps
#gmt grdimage ice_relief.nc -Cetopo1 -R335/63/347/67r -JA341/65/6i -P -I+a15+ne0.75 -Xc -K > $ps


# Add legend
gmt psscale -Dg21.0/35.5+w6.8c/0.15i+v+o0.3/0i+ml -R -J -Cmyocean.cpt \
	--FONT_LABEL=7p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=7p,Helvetica,black \
    --FONT_TITLE=6p,Helvetica,black \
	-Bg500f50a500+l"Color scale: geo [R=-1870/+2649, H=0, C=HSV]" \
	-I0.2 -By+lm -O -K >> $ps
    
# Add shorelines
gmt grdcontour tr_relief.nc -R -J -C1000 -W0.1p -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P \
    -Ia/thinner,blue -Na -N1/thick,red -W0.1p -Df -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=wESN \
    --MAP_TITLE_OFFSET=1.0c \
    --FONT_ANNOT_PRIMARY=7p,Helvetica,black \
    --FONT_LABEL=7p,Helvetica,black \
    -Bpxg2f1a2 -Bpyg2f1a2 -Bsxg2 -Bsyg1 \
    -B+t"Topographic map of Turkey with its global location (insert map)" -O -K >> $ps
    
# Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=7p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Tdx0.8c/0.4c+w0.3i+f2+l+o0.15i \
    -Lx14.5c/-1.3c+c50+w300k+l"Mercator projection. Scale (km)"+f \
    -UBL/-15p/-38p -O -K >> $ps

# City
gmt pstext -R -J -N -O -K \
-F+f10p,Times-Roman,black+jLB -Gwhite@30 >> $ps << EOF
29.0 41.2 Istanbul
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
29.0 41.0 0.15c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,Times-Roman,black+jLB -Gwhite@30 >> $ps << EOF
32.0 39.2 Ankara
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
32.5 39.0 0.15c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,Times-Roman,black+jLB -Gwhite@30 >> $ps << EOF
27.5 38.0 Izmir
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
27.0 38.0 0.15c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,Times-Roman,black+jLB -Gwhite@30 >> $ps << EOF
31.2 37.2 Antalya
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
31.0 37.0  0.15c
EOF
    
# insert map
# Countries codes: ISO 3166-1 alpha-2. Continent codes AF (Africa), AN (Antarctica), AS (Asia), EU (Europe), OC (Oceania), NA (North America), or SA (South America). -EEU+ggrey
#gmt psbasemap -R -J -O -K -DjTR+w1.5i+o0.15i/0.1i+stmp -F+gwhite+p1p+c0.1c+s >> $ps
gmt psbasemap -R -J -O -K -DjTR+w2.0c+o-0.2c/-0.2c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thin,grey -Rg -JG34/39N/$w -Da -Gpeachpuff -A5000 -Bga -Wfaint -ETR+gred -Slightskyblue1 -O -K -X$x0 -Y$y0 >> $ps
#gmt pscoast -Rg -JG12/5N/$w -Da -Gbrown -A5000 -Bg -Wfaint -ECM+gbisque -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx6.2/-2.0+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y1.77c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
3.0 8.9 Digital elevation data: SRTM, 15 arc sec resolution grid
EOF

# Convert to image file using GhostScript
gmt psconvert TopoTR.ps -A0.2c -E720 -Tj -Z
