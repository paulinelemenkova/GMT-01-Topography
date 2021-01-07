#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: Oman)
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
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R51/67/15/28 -Gom_relief.nc
#gmt grdcut GEBCO_2019.nc -R51/61/15/27.5 -Gom_relief.nc
gdalinfo -stats om_relief.nc
#   Minimum=-5115.000, Maximum=2760.000

# Make color palette
gmt makecpt -Cgeo.cpt -V -T-5115/2760 > myocean.cpt

ps=Topo_OM.ps
# Make raster image
gmt grdimage om_relief.nc -Cmyocean.cpt -R51/67/15/28 -JM6.5i -I+a15+ne0.75 -Xc -P -K > $ps

# Add legend
gmt psscale -Dg51/14.0+w16.5c/0.15i+h+o0.0/0i+ml -R -J -Cmyocean.cpt \
	--FONT_LABEL=7p,0,black \
    --MAP_LABEL_OFFSET=0.1c \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_TITLE=6p,0,black \
	-Bg500f50a500+l"Color scale: 'geo' [R=-5358/3447, H=0, C=HSV]" \
	-I0.2 -By+lm -O -K >> $ps
    
# Add isolines
gmt grdcontour om_relief.nc -R -J -C500 -Wthinner,darkbrown -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P \
    -Ia/thinner,blue -Na -N1/thickest,red -W0.1p -Df -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=WEsN \
    --MAP_TITLE_OFFSET=0.8c \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_LABEL=7p,25,black \
    --FONT_TITLE=15p,13,black \
    -Bpxg4f1a2 -Bpyg2f1a2 -Bsxg2 -Bsyg1 \
    -B+t"Topographic map of Oman and Arabian Sea (north)" -O -K >> $ps
    
# Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=7p,0,black \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx14.5c/-2.2c+c50+w200k+l"Mercator projection. Scale (km)"+f \
    -UBL/-3p/-60p -O -K >> $ps

# Texts

# insert map
# Countries codes: ISO 3166-1 alpha-2. Continent codes AF (Africa), AN (Antarctica), AS (Asia), EU (Europe), OC (Oceania), NA (North America), or SA (South America). -EEU+ggrey
gmt psbasemap -R -J -O -K -DjBR+w3.2c+o-0.2c/-0.2c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thin,grey -Rg -JG56/21N/$w -Da -Glightgoldenrod1 -A5000 -Bga -Wfaint -EOM+gred -Sdodgerblue -O -K -X$x0 -Y$y0 >> $ps
#gmt pscoast -Rg -JG12/5N/$w -Da -Gbrown -A5000 -Bg -Wfaint -ECM+gbisque -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx7.0/-2.8+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.1c -Y9.3c -N -O \
    -F+f10p,13,black+jLB >> $ps << EOF
3.0 9.0 Digital elevation data: SRTM/GEBCO, 15 arc sec resolution grid
EOF

# Convert to image file using GhostScript
gmt psconvert Topo_OM.ps -A0.7c -E720 -Tj -Z
