#!/bin/sh

#GLOBE is short for Global Land One-km Base Elevation Project. It is a Digital Elevation Model (DEM).
#Coverage: covers the complete land surface in a resolution of 30 arc seconds, which is twice as high as ETOPO.
#Download: http://www.ngdc.noaa.gov/mgg/topo/gltiles.html

#Conversion to xyz format
#The data is given in gridded binary files, with the elevation stored as 16-bit signed integer numbers.
#These files can be converted to the GMT *.grd format as follows:

xyz2grd a10g -Ggrid_textGLOBE.grd -R-180/-90/50/90 -I30c -N-9999 -V -F -ZTLh

gdalinfo grid_textGLOBE.grd -stats
# z#actual_range={-500,6098}

ps=GLOBE_Canada.ps

# visualization
#gmt grdimage grid_textGLOBE.grd -Csrtm -R-180/-90/50/90 -JQ5.0i -P -I+a15+ne0.75 -Xc > $ps
gmt grdimage grid_textGLOBE.grd -Csrtm -R220/50/270/80r -JA260/60/5.5i -P -I+a15+ne0.75 -Xc -K > $ps


# Add grid
gmt psbasemap -R -J \
    -Bpxg10f5a5 -Bpyg10f5a5 -Bsxg5 -Bsyg5 \
    --MAP_TITLE_OFFSET=1.5c \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,black \
    --FONT_LABEL=6p,Helvetica,black \
    -B+t"Topographic map of the Northern Canada and Alaska based on GLOBE DEM" -O -K >> $ps

# Add legend
gmt psscale -Dg220/49+w15.0c/0.4c+h+o7.0/0.0c+ml -R -J -Csrtm.cpt \
    --FONT_LABEL=8p,Helvetica,dimgray \
    --FONT_ANNOT_PRIMARY=5p,Helvetica,dimgray \
    -Baf+l"Color scale 'srtm': topography relief [R=-500,6098, H=1, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps
    
# Add shorelines
gmt grdcontour grid_textGLOBE.grd -R -J -C3000 -W0.1p -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P \
    -Ia/thinnest,blue -Na -N1/thick,red -W0.2p -Df -O -K >> $ps

# Add scale, directional rose
gmt psbasemap -R -J \
    --FONT_ANNOT_PRIMARY=8p,Helvetica,black \
    --FONT_LABEL=8p,Helvetica,black \
    --MAP_ANNOT_OFFSET=0.1c \
    --MAP_TITLE_OFFSET=0.1c \
    -Lx12.0c/-1.4c+c50+w800k+l"Lambert Azimuthal projection. Scale: km"+f \
    -UBL/-5p/-40p -O -K >> $ps

# Texts
gmt pstext -R -J -N -O -K \
-F+jTL+f13p,Helvetica,white+jLB >> $ps << EOF
224.5 44.1 P A C I F I C
224.5 43.5 O C E A N
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,Helvetica,white+jLB >> $ps << EOF
250 62.0 C  A  N  A  D  A
205 65.0 Alaska
205.7 64.0 (U  S  A)
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,Helvetica,white+jLB >> $ps << EOF
216 75.5 Arctic Ocean
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,Helvetica,white+jLB >> $ps << EOF
220.6 72.0 Beaufort
222 71.0 Sea
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,Helvetica,white+jLB >> $ps << EOF
216 57.0 North
216 56.0 Pacific
216 55.0 Ocean
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Palatino-Italic,blue+jLB+a-75  >> $ps << EOF
229.8 67.5 Mackenzie
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,Palatino-Italic,blue+jLB+a-75 >> $ps << EOF
234.8 68.5 Anderson
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f7p,Palatino-Roman,black+jLB >> $ps << EOF
240.5 77.0 Queen
240.7 76.3 Elizabeth
240.9 75.6 Islands
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,Palatino-Roman,black+jLB -Gwhite@40 >> $ps << EOF
246 71.0 Victoria
246.5 70.3 Island
235.2 73.0 Banks
235.6 72.3 Island
EOF

gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Palatino-Roman,black+jLB -Gwhite@40 >> $ps << EOF
250 65.8 Nunavut
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Palatino-Roman,black+jLB -Gwhite@40 >> $ps << EOF
237 64.0 N.W.T.
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Palatino-Roman,black+jLB -Gwhite@40 >> $ps << EOF
224 63.0 Yukon
EOF

# Add GMT logo
gmt logo -Dx6.0/-2.2+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/14 -X0.5c -Y7.0c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
1.0 7.1 GLOBE 30-arc-second (1-km) gridded DEM, Version 1.0
1.0 6.6 Global Land One-km Base Elevation Project (GLOBE)
EOF
    
# Convert to image file using GhostScript
gmt psconvert GLOBE_Canada.ps -A0.5c -E720 -Tj -Z



#The Global Land One-kilometer Base Elevation (GLOBE) Digital Elevation Model, Version 1.0

# in order to convert all files at once (in the bash shell):

FILES=(*10g)
LAT_S=(50 0 -50 -90)
LAT_N=(90 50 0 -50)
for((y=0; y<=3; y++)); do
    for(( x=0; x<=3; x++)); do
        REGION="$((-180+$x*90))/$((-90+$x*90))/${LAT_S[$y]}/${LAT_N[$y]}"
        xyz2grd ${FILES[$(($y*4+$x))]} -G${files[$(($y*3+$x))]}.grd -R$REGION -I30c -N-9999 -V -F -ZTLh
    done
done

#Then, to get a global xyz file:

{ for i in *.grd; do grd2xyz $i; done; } | sort -k2nr -k1n > globe.xyz

# Source: http://www.earthmodels.org/data-and-tools/topography/globe
