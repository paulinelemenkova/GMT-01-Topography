#!/bin/sh
#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: Japan)
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert
# http://soliton.vm.bytemark.co.uk/pub/cpt-city/njgs/index.html

# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert
# GMT set up
gmt set FORMAT_GEO_MAP=dddF \
    MAP_FRAME_PEN=dimgray \
    MAP_FRAME_WIDTH=0.1c \
    MAP_TITLE_OFFSET=1c \
    MAP_ANNOT_OFFSET=0.1c \
    MAP_TICK_PEN_PRIMARY=thinner,dimgray \
    MAP_GRID_PEN_PRIMARY=thin,white \
    MAP_GRID_PEN_SECONDARY=thinner,white \
    FONT_TITLE=12p,Palatino-Roman,black \
    FONT_ANNOT_PRIMARY=8p,Helvetica,black \
    FONT_LABEL=8p,Helvetica,black \
# Overwrite defaults of GMTs
gmtdefaults -D > .gmtdefaults

# Extract a subset of GEBCO for the Japan trench area
gmt grdcut GEBCO_2019.nc -R128/150/30/46 -Gjp_relief.nc
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R128/150/30/46 -Gjp_relief1.nc

exec bash

#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R128/150/30/46 -JM16c -Dh -M -EJP > Japan.txt
#####################################################################

# Make color palette
gmt makecpt -Cgeo.cpt -V -T-11500/3000 > myocean.cpt

# Generate a file
ps=Topo_JP.ps

# Make raster image
gmt grdimage jp_relief.nc -Cmyocean.cpt -R128/150/30/46 -JM16c -P -I+a15+ne0.75 -Xc -K > $ps

# Add color legend
gmt psscale -Dg124.5/30+w15.0c/0.4c+v+o0.3/0i+ml -R -J -Cmyocean.cpt \
	--FONT_LABEL=10p,0,black \
	--FONT_ANNOT_PRIMARY=8p,0,black \
	-Bg2000f100a1000+l"Topographic color scale" \
	-I0.2 -By+lm -O -K >> $ps
	
# Add isolines
gmt grdcontour jp_relief1.nc -R -J -C2000 -W0.1p -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -Ia/thinner,blue -Na -N1/thicker,red -W0.1p -Df -O -K >> $ps

#####################################################################
# CLIPPING
# 1. Start: clip the map by mask to only include country
gmt psclip -R128/150/30/46 -JM16c Japan.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage jp_relief.nc -Cpauline.cpt -R128/150/30/46 -JM16c -I+a15+ne0.75 -Xc -P -O -K >> $ps

# Add isolines
gmt grdcontour jp_relief1.nc -R -J -C250 -Wthinnest,darkbrown -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps
#gmt pscoast -R -J \
    -Ia/thinner,blue -Na -W0.1p -Df -O -K >> $ps

# 3: Undo the clipping
gmt psclip -C -O -K >> $ps
#####################################################################

# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=wESN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    -Bpxg8f2a4 -Bpyg6f3a3 -Bsxg4 -Bsyg3 \
    -B+t"Topographic map of Japan" -O -K >> $ps
    
# Add projection scale
gmt psbasemap -R -J \
    --FONT=10p,0,dimgray \
    --MAP_TITLE_OFFSET=0.3c \
    -Lx14c/-0.5i+c50+w500k+l"Mercator projection. Scale (km)"+f \
    -UBL/-5p/-40p -O -K >> $ps
    
# Add directional rose
gmt psbasemap -R -J \
    --FONT=9p,Palatino-Roman,white \
    --MAP_TITLE_OFFSET=0.3c \
    -Tdx14.5c/1.5c+w0.3i+f2+l+o0.15i \
    -O -K >> $ps
    
# Texts
gmt pstext -R -J -N -O -K \
-F+f11p,Times-Roman,white+jLB >> $ps << EOF
133 41 SEA OF JAPAN
145.5 35.5 PACIFIC OCEAN
EOF
gmt pstext -R -J -N -O -K \
-F+f8p,Palatino-Roman,black+jLB -Gwhite@30 >> $ps << EOF
142 43.5 HOKKAIDO
130 32.5 KYUSHU
EOF
gmt pstext -R -J -N -O -K \
-F+f8p,Palatino-Roman,black+jLB+a-320 -Gwhite@40 >> $ps << EOF
138 35.8 H O N S H U
EOF

# insert map
# Countries codes: ISO 3166-1 alpha-2
gmt psbasemap -R -J -O -K -DjBL+w3.2c+o-0.2c/-0.2c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thinnest,grey -Rg -JG28.0/-2.0S/$w -Da -Glightgoldenrod1 -A5000 -Bga -Wfaint -EJP+gred -Sdodgerblue -O -K -X$x0 -Y$y0 >> $ps
#gmt pscoast -Rg -JG12/5N/$w -Da -Gbrown -A5000 -Bg -Wfaint -ECM+gbisque -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx6.5/-2.2+o0.1i/0.1i+w2c -O -K >> $ps
# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y8.4c -N -O \
    -F+f10p,0,black+jLB >> $ps << EOF
3.0 11.0 GEBCO DEM Global Relief Model 15 arc sec resolution grid
EOF

# Convert to image file using GhostScript
gmt psconvert Topo_JP.ps -A0.2c -E720 -Tj -Z
