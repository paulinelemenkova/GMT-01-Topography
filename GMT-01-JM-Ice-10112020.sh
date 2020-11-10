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
# 13W25W
#grdcut ETOPO1_Ice_g_gmt4.grd -R335/347/63/67 -Gice_relief.nc
grdcut topo15.grd -R334/347/63/68 -Gice_relief.nc
#grdcut GEBCO_2019.nc -R335/347/63/67 -Gice_relief.nc
gdalinfo -stats ice_relief.nc
# Minimum=-1870.000, Maximum=2649.000

ps=BathymetryIce.ps
# Make color palette
#gmt makecpt -Ctopo.cpt -V -T-1870/2649 > myocean.cpt
#gmt makecpt -Cworld.cpt -V -T-1870/2649 > myocean.cpt
gmt makecpt -Cgeo.cpt -V -T-1870/2649 > myocean.cpt

# Make raster image
#gmt grdimage ice_relief.nc -Cmyocean.cpt -R335/347/63/67 -JM6i -P -I+a15+ne0.75 -Xc -K > $ps
#gmt grdimage ice_relief.nc -Cmyocean.cpt -R335/347/63/67 -JM6i -P -I+a15+ne0.75 -Xc -K > $ps
gmt grdimage ice_relief.nc -Cmyocean.cpt -R335/63/347/67r -JA341/65/6i -P -I+a15+ne0.75 -Xc -K > $ps


# Add legend
gmt psscale -Dg333.7/63+w12.0c/0.15i+v+o0.3/0i+ml -R -J -Cmyocean.cpt \
	--FONT_LABEL=6p,Helvetica,dimgray \
    --FONT_ANNOT_PRIMARY=7p,Helvetica,black \
    --FONT_TITLE=6p,Helvetica,black \
	-Bg500f50a500+l"Color scale: geo [Colors for global bathymetry/topography relief [R=-1870/+2649, H=0, C=HSV]]" \
	-I0.2 -By+lm -O -K >> $ps
    
# Add shorelines
gmt grdcontour ice_relief.nc -R -J -C1000 -W0.1p -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P \
    -Ia/thinner,blue -Na -N1/thickest,red -W0.1p -Df -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=wESN \
    --MAP_TITLE_OFFSET=1.0c \
    --FONT_ANNOT_PRIMARY=7p,Helvetica,black \
    --FONT_LABEL=7p,Helvetica,black \
    -Bpxg2f0.5a1 -Bpyg2f0.25a1 -Bsxg2 -Bsyg1 \
    -B+t"Topographic map of Iceland with study area (red square) and global location (insert map)" -O -K >> $ps
    
# Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=7p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Tdx1.0c/1.3c+w0.3i+f2+l+o0.15i \
    -Lx13.0c/-1.5c+c50+w150k+l"Lambert Azimuthal Equal-Area projection. Scale (km)"+f \
    -UBL/-15p/-38p -O -K >> $ps
    
# Study area
gmt psbasemap -R -J \
    -D339.5/64.7/343.3/66.6r -F+pthick,red \
    -O -K >> $ps
# City
gmt pstext -R -J -N -O -K \
-F+f10p,Times-Roman,black+jLB -Gwhite@30 >> $ps << EOF
338 64.0 Reykjavík
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
338 64.1 0.15c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,Times-Roman,black+jLB+a-74 -Gwhite@30 >> $ps << EOF
339.8 66.5 Skagafjörður
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,Times-Roman,black+jLB+a-71 -Gwhite@30 >> $ps << EOF
341.2 66.5 Eyjafjörður
EOF

# insert map
# Countries codes: ISO 3166-1 alpha-2. Continent codes AF (Africa), AN (Antarctica), AS (Asia), EU (Europe), OC (Oceania), NA (North America), or SA (South America). -EEU+ggrey
#gmt psbasemap -R -J -O -K -DjTR+w1.5i+o0.15i/0.1i+stmp -F+gwhite+p1p+c0.1c+s >> $ps
gmt psbasemap -R -J -O -K -DjTL+w3.0c+o-0.1c/-0.1c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thin,grey -Rg -JG-20/65N/$w -Da -Gpeachpuff -A5000 -Bga -Wfaint -EIS+gred -Sazure -O -K -X$x0 -Y$y0 >> $ps
#gmt pscoast -Rg -JG12/5N/$w -Da -Gbrown -A5000 -Bg -Wfaint -ECM+gbisque -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx6.2/-2.2+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y7.1c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
3.0 8.9 Digital elevation data: SRTM, 15 arc sec resolution grid
EOF

# Convert to image file using GhostScript
gmt psconvert BathymetryIce.ps -A0.2c -E720 -Tj -Z
