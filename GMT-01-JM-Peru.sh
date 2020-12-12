#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO dataset (here: Peru)
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

gmt grdcut GEBCO_2019.nc -R278/292/-21/3 -Gperu_relief.nc
#gmt grdcut ETOPO1_Ice_g_gmt4.grd -R278/292/-21/3 -Gperu_relief.nc
#263/278

gdalinfo peru_relief.nc -stats
# -7668,6151
# Make color palette
# makecpt --help
#gmt makecpt -Cdem3.cpt -V -T-6857/3206 > myocean.cpt
#gmt makecpt -Cdem2.cpt -V -T-6857/3206 > myocean.cpt
gmt makecpt -Cgeo.cpt -V -T-7668/6151 > myocean.cpt

# Generate a file
ps=Topography_Peru.ps
# Make raster image
gmt grdimage peru_relief.nc -Cmyocean.cpt -R278/292/-21/3 -JM6i -P -I+a15+ne0.75 -Xc -K > $ps

# Add grid
gmt psbasemap -R -J \
    -Bpx1f1a2 -Bpyg1f1a2 -Bsxg1 -Bsyg1 \
    --MAP_TITLE_OFFSET=1.2c \
    --FONT_TITLE=14p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=7p,Helvetica,black \
    -B+t"Topographic map of Peru" -O -K >> $ps
    
# Add shorelines
gmt grdcontour peru_relief.nc -R -J -C1000 -W0.1p -O -K >> $ps
    
# Add scale, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=10p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=8p,Helvetica,black \
    --MAP_LABEL_OFFSET=0.1c \
    -Lx12.7c/-2.3c+c50+w300k+l"Mercator projection. Scale: km"+f \
    -UBL/-5p/-65p -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P \
    -Ia/thinner,blue -Na -N1/thickest,red -W0.1p -Df -O -K >> $ps

# Add legend
gmt psscale -Dg278/-22.1+w15.2c/0.4c+h+o0.0/0i+ml -R -J -Cmyocean.cpt \
    --FONT_LABEL=8p,Helvetica,black \
    --MAP_LABEL_OFFSET=0.1c \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,black \
    -Baf+l"Color scale 'geo': global bathymetry/topography relief [R=-6857/3206, H=0, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps
    
# Texts
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,Helvetica,black+jLB -Gwhite@20 -Wthinnest >> $ps << EOF
283 -8.5 P  E  R  U
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,Helvetica,black+jLB -Gwhite@30 -Wthinnest >> $ps << EOF
280 -1.5 ECUADOR
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,Helvetica,black+jLB -Gwhite@40 -Wthinnest >> $ps << EOF
289 -7.5 B R A S I L
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,Helvetica−Narrow−Oblique,black+jLB -Gwhite@40 -Wthinnest >> $ps << EOF
290 -21.0 CHILE
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,Helvetica−Narrow−Oblique,black+jLB -Gwhite@40 -Wthinnest >> $ps << EOF
290.5 -17.5 BOLIVIA
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,Helvetica−Narrow−Oblique,black+jLB -Gwhite@40 -Wthinnest >> $ps << EOF
285 1.5 COLOMBIA
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,Helvetica−Narrow−Oblique,black+jLB -Gwhite@30 -Wthinnest >> $ps << EOF
283 -11.6 Lima
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
283 -12.0 0.3c
EOF

# insert map
# Countries codes: ISO 3166-1 alpha-2. Continent codes AF (Africa), AN (Antarctica), AS (Asia), EU (Europe), OC (Oceania), NA (North America), or SA (South America). -EEU+ggrey
gmt psbasemap -R -J -O -K -DjTR+w3.7c+o-0.2c/-0.2c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thin,grey -Rg -JG285/8S/$w -Da -Gbrown -A5000 -Bg -Wfaint -ESA+gpeachpuff -EPE+gyellow -Slightskyblue1 -O -K -X$x0 -Y$y0 >> $ps
#gmt pscoast -Rg -JG12/5N/$w -Da -Gbrown -A5000 -Bg -Wfaint -ECM+gbisque -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx6.2/-3.0+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y18.5c -N -O \
    -F+f12p,Helvetica,black+jLB >> $ps << EOF
1.0 13.6 SRTM/GEBCO 15 arc sec resolution global terrain model grid
EOF

# Convert to image file using GhostScript
gmt psconvert Topography_Peru.ps -A2.0c -E720 -Tj -Z
