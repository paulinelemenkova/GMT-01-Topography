#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: Jordan)
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
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R34/40/29/34 -Gjo_relief1.nc
gmt grdcut GEBCO_2019.nc -R34/40/29/34 -Gjo_relief.nc
gdalinfo -stats jo_relief.nc
# Minimum=-2191.000, Maximum=2635.000

# Make color palette
gmt makecpt -Csrtm.cpt -V -T-2191/2635 > myocean.cpt
# srtm
# relief etopo1 dem1, dem2, dem3 earth elevation

ps=Topo_JO.ps
# Make raster image
gmt grdimage jo_relief.nc -Cmyocean.cpt -R34/40/29/34 -JM6.5i -I+a15+ne0.75 -Xc -K > $ps

# Add legend
gmt psscale -Dg33.3/29.0+w16.0c/0.15i+v+o0.3/0i+ml -R -J -Cmyocean.cpt \
	--FONT_LABEL=7p,0,black \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_TITLE=6p,0,black \
	-Bg500f50a500+l"Color palette scale: 'srtm' [R=-5358/3447, H=0, C=RGB]" \
	-I0.2 -By+lm -O -K >> $ps
    
# Add isolines
gmt grdcontour jo_relief1.nc -R -J -C250 -Wthinner,darkbrown -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P \
    -Ia/thinner,blue -Na -N1/thick,khaki1 -W0.1p -Df -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=wESN \
    --MAP_TITLE_OFFSET=0.9c \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_LABEL=7p,25,black \
    --FONT_TITLE=17p,25,black \
    -Bpxg2f1a1 -Bpyg2f1a1 -Bsxg2 -Bsyg1 \
    -B+t"Topographic map of Jordan" -O -K >> $ps
    
# Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=7p,0,black \
    --FONT_ANNOT_PRIMARY=6p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx14.5c/-1.3c+c50+w120k+l"Mercator projection. Scale (km)"+f \
    -UBL/-15p/-38p -O -K >> $ps

# Texts

# insert map
# Countries codes: ISO 3166-1 alpha-2. Continent codes AF (Africa), AN (Antarctica), AS (Asia), EU (Europe), OC (Oceania), NA (North America), or SA (South America). -EEU+ggrey
gmt psbasemap -R -J -O -K -DjTL+w3.6c+o-0.2c/-0.2c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thin,white \
    --MAP_FRAME_PEN=thick,khaki1 \
    -Rg -JG37.0/31.5N/$w -Da -Ggold -A5000 -Bga -Wfaint -EJO+gred2 -Sroyalblue1 -O -K -X$x0 -Y$y0 >> $ps
#gmt pscoast -Rg -JG12/5N/$w -Da -Gbrown -A5000 -Bg -Wfaint -ECM+gbisque -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx7.0/-2.0+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.1c -Y10.8c -N -O \
    -F+f10p,25,black+jLB >> $ps << EOF
3.0 9.0 Digital elevation data: SRTM/GEBCO, 15 arc sec resolution grid
EOF

# Convert to image file using GhostScript
gmt psconvert Topo_JO.ps -A0.2c -E720 -Tj -Z


#####################################################################
# Grayscale topography of Jordan with water areas
ps=Topo_JO.ps
# Make raster image
gmt grdimage jo_relief.nc -Cmyocean.cpt -R34/40/29/34 -JM6.5i -I+a15+ne0.75 -Xc -P -K > $ps

# Then use pscoast to initiate clip path for Jordan
gmt pscoast -R -J -EJO -Gc -O -K >> $ps
# Now generate topography image w/shading
echo "-10000 150 10000 150" > gray.cpt
gmt grdgradient jo_relief.nc -Nt1 -A45 -Gjordan_topo_i.nc
gmt grdimage jo_relief.nc -Ijordan_topo_i.nc -J -Cgray.cpt -O -K >> $ps
# Finally undo clipping and overlay basemap
gmt pscoast -R -J -O -K -Q -B10f5:."Clipping of Images": >> $ps

gmt grdimage -J -R ETOPO1_Ice_g_gmt4.grd -Csrtm -O -K >> jordan.ps
gmt pscoast -Q -O >> jordan.ps


#####################################################################
ps=Topo_JO.ps
# Make raster image
#gmt grdimage jo_relief.nc -Cmyocean.cpt -R34/40/29/34 -JM6.5i -I+a15+ne0.75 -Xc -P -K > $ps

gmt psbasemap -R34/40/29/34 -JM6.5i -P -B4f2g0  -K > $ps
# Clip the map to only include Iran
gmt psclip -JM -R jordan.txt -O -K >> $ps

gmt grdimage jo_relief.nc -Cmyocean.cpt -R34/40/29/34 -JM6.5i -I+a15+ne0.75 -Xc -P -O -K >> $ps

# Undo the clipping
gmt psclip -C -O -K >> $ps

#####################################################################
# MASK of Jordan (RED)
gmt pscoast -R34/40/29/34 -JM6.5i -Bga -EJO+gred -P -K > jordan.ps
#####################################################################

# Then use pscoast to initiate clip path for Jordan
gmt pscoast -R -J -EJO -Gc -O -K >> $ps


# DCW
#Usage https://docs.generic-mapping-tools.org/6.1/datasets/dcw.html

#DCW-GMT is an optional install. If you did install it then you can access the DCW data for plotting or analysis via the coast module. You can also use the ISO 2-character codes for countries as a way to specify map domains via the -R option. For instance, to make a map showing France with a region rounded to the nearest 2 degrees in longitude and latitude, you can run:

gmt coast -RFR+r2 -Glightgray -B -pdf france
gmt coast -RJO+r1 -Glightgray -B -pdf jordan.grd

#If we in addition want to paint the landmass of France blue, we run:

gmt pscoast -RFR+r2 -Glightgray -B -EFR+gblue -pdf france
gmt pscoast -RJO+r2 -Glightgray -B -EJO+gblue -pdf jordan
gmt pscoast -R34/40/29/34 -Dh -W -M > jordan.txt
gmt pscoast -R-26/-12/62/68 -Dh -W -M > iceland.txt

#To access states without countries you must use the country.state syntax. See the coast documentation for details. For instance, to make a map of the US and show Texas and Mississippi as red states, try:

gmt coast -RUS+r2 -Glightgray -B -EUS.TX,US.MS+gred -pdf us

gmt pscoast -R34/40/29/34 -JM6.5i -Dh -M -EJO > jordan.txt


