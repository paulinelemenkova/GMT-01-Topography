#!/bin/sh
# Purpose: shaded relief grid raster map from the SRTM from 1 arc minute global data set
# here: New Britain - San Cristobal trenches
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert

# Step-1. GMT set up
gmt set FORMAT_GEO_MAP=dddF \
    MAP_FRAME_PEN=dimgray \
    MAP_FRAME_WIDTH=0.1c \
    MAP_TITLE_OFFSET=1c \
    MAP_ANNOT_OFFSET=0.1c \
    MAP_TICK_PEN_PRIMARY=thinner,dimgray \
    MAP_GRID_PEN_PRIMARY=thin,white \
    MAP_GRID_PEN_SECONDARY=thinnest,white \
    FONT_TITLE=12p,Palatino-Roman,black \
    FONT_ANNOT_PRIMARY=8p,Helvetica,black \
    FONT_LABEL=8p,Helvetica,black \
# Step-2. Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults

# Step-3. Extract a subset of SRTM for the New Britain - San Cristobal trenches area
grdcut topo15.grd -R140/162/-15/0 -Gnbt_relief.nc
gdalinfo nbt_relief.nc -stats
# Minimum=-9100.808, Maximum=4660.000

# Step-4. Make color palette
gmt makecpt -Cgeo.cpt -V -T-9200/5000 > myocean.cpt

# Step-5. Generate a file
ps=BathyNBT_SRTM.ps

# Step-6. Make raster image
gmt grdimage nbt_relief.nc -Cmyocean.cpt -R140/162/-15/0 -JM16c -P -I+a15+ne0.75 -Xc -K > $ps

# Step-7. Add color legend
gmt psscale -Dg137.5/-15+w11.0c/0.4c+v+o0.3/0i+ml -Rnbt_relief.nc -J -Cmyocean.cpt \
	--FONT_LABEL=8p,Helvetica,dimgray \
	--FONT_ANNOT_PRIMARY=6p,Helvetica,black \
	-Ba2000g1000f100+l"Color scale 'geo': global bathymetry/topography relief [R=-9200/5000, H=0, C=RGB]" \
	-I0.2 -By+lm -O -K >> $ps
    
# Step-8. Add shorelines
gmt grdcontour nbt_relief.nc -R -J -C1000 -W0.1p -O -K >> $ps

# Step-9. Add grid
gmt psbasemap -R -J \
    --MAP_TITLE_OFFSET=1.0c \
    --FONT_ANNOT_PRIMARY=7p,Helvetica,black \
    --MAP_FRAME_AXES=wESN \
    -Bpxg8f2a4 -Bpyg6f3a3 -Bsxg4 -Bsyg3 \
    -B+t"Topographic map of the New Britain and San Cristobal trenches region" -O -K >> $ps
    
# Step-10. Add projection scale
gmt psbasemap -R -J \
    --FONT=9p,Palatino-Roman,dimgray \
    --MAP_TITLE_OFFSET=0.3c \
    -Lx14c/-0.5i+c50+w400k+l"Mercator projection. Scale (km)"+f \
    -UBL/-5p/-40p -O -K >> $ps
    
# Step-10. Add directional rose
gmt psbasemap -R -J \
    --FONT=9p,Palatino-Roman,white \
    --MAP_TITLE_OFFSET=0.3c \
    -Tdx13.5c/1.0c+w0.3i+f2+l+o0.15i \
    -O -K >> $ps
    
# texts
gmt pstext -R -J -N -O -K \
    -F+f8p,Palatino-Roman,black+jLB+a-10 -Gwhite@30 >> $ps << EOF
147 -1.6 BISMARK ARCHIPELAGO
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,Palatino-Roman,red+jLB+a-338 -Gwhite@30 >> $ps << EOF
149.4 -7.6 New Britain Trench  .
EOF
gmt pstext -R -J -N -O -K \
    -F+f9p,Palatino-Roman,red+jLB+a-37 -Gwhite@30 >> $ps << EOF
153.0 -6.1 S  a  n   C  r  i  s  t  o  b  a  l   .
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,Palatino-Roman,red+jLB+a-28 -Gwhite@30 >> $ps << EOF
157.3 -9.3 T  r  e  n  c  h
EOF
gmt pstext -R -J -N -O -K \
    -F+f8p,Palatino-Roman,black+jLB+a-340 -Gwhite@30 >> $ps << EOF
150 -6.0 New Britain
EOF
gmt pstext -R -J -N -O -K \
    -F+f8p,Palatino-Roman,black+jLB -Gwhite@30 >> $ps << EOF
151.9 -3.0 New Ireland
155.4 -5.8 Bougainville
156.9 -6.6 Choiseul
158.0 -7.3 Santa Isabel
160 -8.0 Malaita
159.5 -11.2 San Cristobal
EOF
gmt pstext -R -J -N -O -K \
    -F+f8p,Palatino-Roman,black+jLB+a-16 -Gwhite@30 >> $ps << EOF
150.5 -11.5 Louisiade Archipelago
EOF
gmt pstext -R -J -N -O -K \
    -F+f8p,Palatino-Roman,black+jLB+a-25 -Gwhite@30 >> $ps << EOF
156.5 -7.5 SOLOMON ISLANDS
EOF
gmt pstext -R -J -N -O -K \
    -F+f9p,Times-Roman,black+jLB -Gwhite@20 -Wthinnest,darkbrown >> $ps << EOF
141 -5.5 PAPUA NEW GUINEA
141.9 -14.9 AUSTRALIA
EOF
gmt pstext -R -J -N -O -K \
    -F+f11p,Times-Roman,white+jLB >> $ps << EOF
149.5 -13.5 C O R A L  S E A
150.8 -7.5 S O L O M O N
152.1 -8.0 S E A
EOF
gmt pstext -R -J -N -O -K \
    -F+f11p,Times-Roman,darkblue+jLB -Gwhite@30 >> $ps << EOF
146 -3.8 B I S M A R K  S E A
153.5 -1.0 P A C I F I C
153.5 -1.5 O C E A N
EOF
gmt pstext -R -J -N -O -K \
    -F+jTL+f9p,Times-Roman,white=0.1p,black+jLB >> $ps << EOF
144.2 -8.5 Gulf of
144.2 -8.8 Papua
EOF
# Step-7. Square of study area
#gmt psbasemap -R -J \
#    -D149.0/-8.8/156.5/-5.0r -F+pthicker,yellow \
#    -O -K >> $ps
gmt psbasemap -R -J \
    -D149.0/-10.5/161.0/-5.0r -F+pthicker,yellow \
    -O -K >> $ps

# insert map
# Countries codes: ISO 3166-1 alpha-2. Continent codes AF (Africa), AN (Antarctica), AS (Asia), EU (Europe), OC (Oceania), NA (North America), or SA (South America).
#gmt psbasemap -R -J -O -K -DjTR+w1.5i+o0.15i/0.1i+stmp -F+gwhite+p1p+c0.1c+s >> $ps
gmt psbasemap -R -J -O -K -DjTR+w3.0c+o0.3c/0.2c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thin,grey -Rg -JG150/10S/$w -Da -Gbrown -A5000 -Bg -Wfaint -EAS+gpeachpuff -EPG+gyellow -Sazure1 -O -K -X$x0 -Y$y0 >> $ps
#gmt pscoast -Rg -JG12/5N/$w -Da -Gbrown -A5000 -Bg -Wfaint -ECM+gbisque -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Step-11. Add GMT logo
gmt logo -Dx6.5/-2.0+o0.1i/0.1i+w2c -O -K >> $ps

# Step-12. Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y5.2c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
3.0 10.0 SRTM Global Relief Model 15 arc sec resolution grid
EOF

# Step-13. Convert to image file using GhostScript
gmt psconvert BathyNBT_SRTM.ps -A0.2c -E720 -Tj -Z
