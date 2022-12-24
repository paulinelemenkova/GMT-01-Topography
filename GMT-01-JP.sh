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
    FONT_TITLE=12p,0,black \
    FONT_ANNOT_PRIMARY=8p,Helvetica,black \
    FONT_LABEL=8p,Helvetica,black \
# Overwrite defaults of GMTs
gmtdefaults -D > .gmtdefaults

# Extract a subset of GEBCO for the Japan trench area
gmt grdcut GEBCO_2019.nc -R128/150/30/46 -Gjp_relief.nc
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R128/150/30/46 -Gjp_relief1.nc

gmt grdgdal -Ainfo jp_relief.nc
# actual_range={-9759.701171875,3700.7421875}

exec bash

#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R128/150/30/46 -JM16c -Dh -M -EJP > Japan.txt
#####################################################################

# Make color palette
gmt makecpt -Cgeo.cpt -V -T-9759/3700 > myocean.cpt

# Generate a file
ps=Topo_JP.ps

# Make raster image
gmt grdimage jp_relief.nc -Cmyocean.cpt -R128/150/30/46 -JM16c -P -I+a15+ne0.75 -Xc -K > $ps

# Add color legend
gmt psscale -Dg125.0/30+w15.0c/0.4c+v+o0.3/0i+ml -R -J -Cmyocean.cpt \
	--FONT_LABEL=10p,0,black \
	--FONT_ANNOT_PRIMARY=8p,0,black \
	-Bg2000f100a1000+l"Topographic color scale" \
	-I0.2 -By+lm -O -K >> $ps
	
# Add isolines
gmt grdcontour jp_relief1.nc -R -J -C2000 -W0.1p -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -Ia/thinner,blue -Na -N1/thin,red -W0.1p -Df -O -K >> $ps

# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=wESN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    --FONT_TITLE=14p,0,black \
    --MAP_TITLE_OFFSET=0.8c \
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
    -Tdx14.5c/9.5c+w0.3i+f2+l+o0.15i \
    -O -K >> $ps
    
# Texts
gmt pstext -R -J -N -O -K \
-F+f12p,0,white+jLB >> $ps << EOF
133 41 SEA OF JAPAN
144.05 37.5 P A C I F I C  O C E A N
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,0,black+jLB -Gwhite@60 >> $ps << EOF
142 43.4 HOKKAIDO
130 32.5 KYUSHU
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,0,black+jLB+a-320 -Gwhite@50 >> $ps << EOF
138 35.8 H O N S H U
EOF

# -R128/150/30/46
gmt pstext -R -J -N -O -K \
-F+f14p,22,black+jLB -Gwhite@50 >> $ps << EOF
139.69 35.79 Tokyo
EOF
gmt psxy -R -J -Ss -W0.5p -Gred -O -K << EOF >> $ps
139.69 35.69 0.30c
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,21,black+jLB -Gwhite@50 >> $ps << EOF
139.63 35.30 Yokohama
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
139.63 35.44 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,21,black+jLB -Gwhite@50 >> $ps << EOF
135.60 34.59 Osaka
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
135.50 34.69 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,21,black+jLB -Gwhite@50 >> $ps << EOF
137.0 35.08 Nagoya
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
136.9 35.18 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,21,black+jLB -Gwhite@50 >> $ps << EOF
141.35 43.16 Sapporo
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
141.35 43.06 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,21,black+jLB -Gwhite@50 >> $ps << EOF
130.4 33.72 Fukuoka
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
130.4 33.58 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,21,black+jLB -Gwhite@50 >> $ps << EOF
134.69 34.79 Kobe
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
135.19 34.69 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,21,black+jLB -Gwhite@50 >> $ps << EOF
139.7 35.62 Kawasaki
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
139.7 35.52 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,21,black+jLB -Gwhite@50 >> $ps << EOF
135.77 35.16 Kyoto
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
135.77 35.01 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,21,black+jLB -Gwhite@50 >> $ps << EOF
139.64 36.01 Saitama
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
139.64 35.86 0.20c
EOF

# insert global map (Countries codes: ISO 3166-1 alpha-2)
gmt psbasemap -R -J -O -K -DjBR+w3.2c+o-0.2c/-0.2c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thinnest,lightgray -Rg -JG140/37N/$w -Da -Gwheat3 -A2000 -Bga -Wfaint -EJP+gyellow -Sslategray3 -O -K -X$x0 -Y$y0 >> $ps
#gmt pscoast -Rg -JG12/5N/$w -Da -Gbrown -A5000 -Bg -Wfaint -ECM+gbisque -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps
# lightskyblue1

# Add GMT logo
gmt logo -Dx6.7/-1.8+o0.1i/0.1i+w2c -O -K >> $ps
# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y8.4c -N -O \
    -F+f10p,0,black+jLB >> $ps << EOF
3.0 11.0 GEBCO DEM Global Relief Model 15 arc sec resolution grid
EOF

# Convert to image file using GhostScript
gmt psconvert Topo_JP.ps -A0.2c -E720 -Tj -Z
