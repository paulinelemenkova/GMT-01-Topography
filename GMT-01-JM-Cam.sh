#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO dataset (here: Cameroon)
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
    FONT_LABEL=7p,Helvetica,dimgray
# Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults

grdcut GEBCO_2019.nc -R8/18/0/14 -Gcam_relief.nc
#grdcut ETOPO1_Ice_g_gmt4.grd -R8/18/0/14 -Gcam_relief.nc

gdalinfo cam_relief.nc -stats
# Minimum=-2601.000, Maximum=3703.000
# Make color palette
# makecpt --help
#gmt makecpt -Cdem3.cpt -V -T-6857/3206 > myocean.cpt
#gmt makecpt -Cdem2.cpt -V -T-6857/3206 > myocean.cpt
gmt makecpt -Cgeo.cpt -V -T-2601/3703 > myocean.cpt

# Generate a file
ps=Topography_Cam.ps
# Make raster image
gmt grdimage cam_relief.nc -Cmyocean.cpt -R8/18/0/14 -JM6i -P -I+a15+ne0.75 -Xc -K > $ps

# Add grid
gmt psbasemap -R -J \
    -Bpx1f0.5a1 -Bpyg1f0.5a1 -Bsxg1 -Bsyg1 \
    --MAP_TITLE_OFFSET=0.8c \
    --FONT_TITLE=14p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=7p,Helvetica,black \
    -B+t"Topographic map of the Republic of Cameroon" -O -K >> $ps
    
# Add shorelines
gmt grdcontour cam_relief.nc -R -J -C800 -W0.1p -O -K >> $ps
    
# Add scale, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=10p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=8p,Helvetica,black \
    --MAP_LABEL_OFFSET=0.1c \
    -Lx12.7c/-1.5c+c50+w200k+l"Mercator projection. Scale: km"+f \
    -UBL/-5p/-45p -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P \
    -Ia/thinner,blue -Na -N1/thickest,red -W0.1p -Df -O -K >> $ps

# Add legend
gmt psscale -Dg39/-29.5+w15.2c/0.4c+h+o0.0/0i+ml -R -J -Cmyocean.cpt \
    --FONT_LABEL=8p,Helvetica,black \
    --MAP_LABEL_OFFSET=0.1c \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,black \
    -Baf+l"Color scale 'geo': global bathymetry/topography relief [R=-6857/3206, H=0, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps

# Texts
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,Helvetica,yellow+jLB+a-53 >> $ps << EOF
8.2 3.0 Gulf of
8.2 2.1 Guinea
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,Helvetica,black+jLB -Gwhite@40 -Wthinnest >> $ps << EOF
11.2 4.5 C A M E R O O N
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,Helvetica,black+jLB -Gwhite@40 -Wthinnest >> $ps << EOF
9.7 1.6 Equatorial
10.0 1.2 Guinea
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,Helvetica,black+jLB -Gwhite@40 -Wthinnest >> $ps << EOF
11.5 0.5 Gabon
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,Helvetica−Narrow−Oblique,black+jLB -Gwhite@40 -Wthinnest >> $ps << EOF
12.1 6.1 Yaoundé
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
12.0 6.0 0.15c
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,Helvetica,black+jLB -Gwhite@40 -Wthinnest >> $ps << EOF
11.5 10.5 Nigeria
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,Helvetica,black+jLB -Gwhite@40 -Wthinnest >> $ps << EOF
9.2 13.5 Niger
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,Helvetica,black+jLB -Gwhite@40 -Wthinnest >> $ps << EOF
16.5 9.5 Chad
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,Helvetica,black+jLB -Gwhite@40 -Wthinnest >> $ps << EOF
16.5 6.5 Central
16.5 6.0 African
16.5 5.5 Republic
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,Helvetica,black+jLB -Gwhite@40 -Wthinnest >> $ps << EOF
15.5 0.5 Congo
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,Times−Italic,blue+jLB+a-332 -Gwhite@40 -Wthinnest >> $ps << EOF
8.7 7.9 Benue River
EOF

# insert map
#gmt psbasemap -R -J -O -K -DjTR+w1.5i+o0.15i/0.1i+stmp -F+gwhite+p1p+c0.1c+s >> $ps
gmt psbasemap -R -J -O -K -DjTR+w1.5i+o0.15i/0.1i+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thin,grey -Rg -JG12/5N/$w -Da -Gbrown -A5000 -Bg -Wfaint -EAF+gpeachpuff -ECM+gyellow -Sazure1 -O -K -X$x0 -Y$y0 >> $ps
#gmt pscoast -Rg -JG12/5N/$w -Da -Gbrown -A5000 -Bg -Wfaint -ECM+gbisque -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx6.2/-2.3+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y13.0c -N -O \
    -F+f12p,Helvetica,black+jLB >> $ps << EOF
1.0 13.6 SRTM/GEBCO 15 arc sec resolution global terrain model grid
EOF

# Convert to image file using GhostScript
gmt psconvert Topography_Cam.ps -A1.0c -E720 -Tj -Z
