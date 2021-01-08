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
gmt makecpt -Csrtm.cpt -V -T-2191/2635 -A50 > myocean.cpt
# srtm
# -A Set constant transparency for all colors
# relief etopo1 dem1, dem2, dem3 earth elevation


#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R34/40/29/33.5 -JM6.5i -Dh -M -EJO > jordan.txt

# Grayscale topography of Jordan with water areas
ps=Topo_JO.ps
# Make raster image
gmt grdimage jo_relief.nc -Cmyocean.cpt -R34/40/29/33.4 -JM6.5i -I+a15+ne0.75 -Xc -P -K > $ps

# Add legend
gmt psscale -Dg33.3/29.0+w14.1c/0.15i+v+o0.3/0i+ml -R -J -Cmyocean.cpt \
    --FONT_LABEL=7p,0,black \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_TITLE=6p,0,black \
    -Bg500f50a500+l"Color palette scale: 'srtm' [R=-2191/2635, H=0, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps

# pscoast to initiate clip path for Jordan
gmt pscoast -R -J -EJO -Gc -O -K >> $ps
# generate topography image w/shading
echo "-10000 150 10000 150" > gray.cpt
gmt grdgradient jo_relief.nc -Nt1 -A45 -Gjordan_topo_i.nc
gmt grdimage jo_relief.nc -Ijordan_topo_i.nc -J -Cgray.cpt -O -K >> $ps
# Add isolines
gmt grdcontour jo_relief1.nc -R -J -C500 -Wthinnest,dimgray -O -K >> $ps
# finish clipping and overlay basemap
gmt pscoast -R -J -O -K -Q >> $ps

# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=wESN \
    --MAP_TITLE_OFFSET=0.9c \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_LABEL=7p,25,black \
    --FONT_TITLE=14p,25,black \
    -Bpxg2f0.5a1 -Bpyg2f0.5a1 -Bsxg2 -Bsyg1 \
    -B+t"Topographic map of Jordan clipped and overlaid on the grayscale relief DEM" -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P \
    -Ia/thinner,blue -Na -N1/thickest,khaki1 -W0.1p -Df -O -K >> $ps

# 3 steps of clipping
# 1. Start: clip the map by mask to only include Jordan
gmt psclip -JM -R jordan.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage jo_relief.nc -Cmyocean.cpt -R34/40/29/34 -JM6.5i -I+a15+ne0.75 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour jo_relief1.nc -R -J -C500 -Wthinnest,navajowhite1 -O -K >> $ps
# Add coastlines, borders, rivers
gmt pscoast -R -J -P \
    -Ia/thinner,blue -Na -N1/thickest,khaki1 -W0.1p -Df -O -K >> $ps

# 3: Undo the clipping
gmt psclip -C -O -K >> $ps

# Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=7p,0,black \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx14.5c/-1.3c+c50+w120k+l"Mercator projection. Scale (km)"+f \
    -UBL/-15p/-38p -O -K >> $ps

# Texts
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,25,chartreuse1+jLB >> $ps << EOF
36.5 33.1 S Y R I A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,25,chartreuse1+jLB >> $ps << EOF
34.5 31.1 I S R A E L
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,25,chartreuse1+jLB >> $ps << EOF
38.8 31.2 S   A   U   D   I
38.8 30.7 A  R  A  B  I  A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,25,chartreuse1+jLB >> $ps << EOF
39.4 32.7 I R A Q
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,25,chartreuse1+jLB -Gdimgray@60 >> $ps << EOF
34.1 29.9 E G Y P T
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,25,chartreuse1+jLB+a-330 -Gdimgray@60 >> $ps << EOF
35.2 33.1 LEBANON
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,25,chartreuse1+jLB -Gdimgray@60 >> $ps << EOF
35.1 32.1 WEST
35.1 31.9 BANK
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,13,white+jLB >> $ps << EOF
34.1 33.1 Mediterranean
34.1 32.8 Sea
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,13,white+jLB+a-288 >> $ps << EOF
34.8 29.0 Red Sea
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,13,white+jLB+a-280 >> $ps << EOF
35.5 31.2 Dead Sea
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,13,blue1+jLB+a-285 -Gdimgray@70 >> $ps << EOF
35.3 32.6 Sea of
35.4 32.6 Galilee
EOF

# Cities
gmt pstext -R -J -N -O -K \
-F+f12p,13,white+jLB >> $ps << EOF
35.7 31.5 Amman
EOF
gmt psxy -R -J -Ss -W0.5p -Gred -O -K << EOF >> $ps
35.6 31.5 0.35c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,13,white+jLB+a-355 >> $ps << EOF
35.7 32.3 Irbid
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
35.6 32.3 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,13,white+jLB >> $ps << EOF
36.2 32.2 Mafraq
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
36.1 32.2 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,13,white+jLB+a-355 >> $ps << EOF
35.7 32.1 Jerash
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
35.6 32.1 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,13,white+jLB+a-355 >> $ps << EOF
35.7 32.2 Ajloun
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
35.6 32.2 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,13,white+jLB >> $ps << EOF
36.1 32.0 Zarqa
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
36.0 32.0 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,13,white+jLB+a-355 >> $ps << EOF
35.7 32.0 Al-Salt
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
35.6 32.0 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,13,white+jLB >> $ps << EOF
35.7 31.3 Madaba
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
35.6 31.4 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,13,white+jLB >> $ps << EOF
35.7 31.1 Al-Karak
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
35.6 31.1 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,13,white+jLB >> $ps << EOF
35.1 29.5 Aqaba
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
35.0 29.5 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,13,white+jLB >> $ps << EOF
35.5 30.1 Ma'an
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
35.4 30.1 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,13,white+jLB >> $ps << EOF
35.5 30.5 Tafilah
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
35.4 30.5 0.20c
EOF

# insert map
# Countries codes: ISO 3166-1 alpha-2. Continent codes AF (Africa), AN (Antarctica), AS (Asia), EU (Europe), OC (Oceania), NA (North America), or SA (South America). -EEU+ggrey
gmt psbasemap -R -J -O -K -DjBR+w4.0c+o-0.0c/-0.0c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thin,white \
    --MAP_FRAME_PEN=thick,khaki1 \
    -Rg -JG37.0/31.5N/$w -Da -Ggold -A5000 -Bga -Wfaint -EJO+gred2 -Sroyalblue1 -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx7.0/-2.0+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.1c -Y9.0c -N -O \
    -F+f10p,25,black+jLB >> $ps << EOF
3.0 9.0 DEM: SRTM/GEBCO, 15 arc sec resolution grid, country mask: DCW.
EOF

# Convert to image file using GhostScript
gmt psconvert Topo_JO.ps -A0.2c -E720 -Tj -Z




# Short variant: only clipped polygon, w/o grayscale DEM
#####################################################################
# create mask of vector layer by DCW of country's polygon
gmt pscoast -R33.5/40/29/34 -JM6.5i -Dh -M -EJO > jordan.txt

# strat file
ps=Topo_JO.ps

# make basemap
gmt psbasemap -R34/40/29/34 -JM6.5i -P -B4f2g0  -K > $ps

# 3 steps of clipping
# 1. Start: clip the map by mask to only include Jordan
gmt psclip -JM -R jordan.txt -O -K >> $ps

# 2. create raster image
gmt grdimage jo_relief.nc -Cmyocean.cpt -R34/40/29/34 -JM6.5i -I+a15+ne0.75 -Xc -P -O -K >> $ps

# 3: Undo the clipping
gmt psclip -C -O >> $ps

#####################################################################
# MASK of Jordan (RED)
gmt pscoast -R34/40/29/34 -JM6.5i -Bga -EJO+gred -P -K > jordan.ps
#####################################################################


gmt coast -RJO+r1 -Glightgray -B -pdf jordan.grd

#If we in addition want to paint the landmass of France blue, we run:
gmt pscoast -RJO+r2 -Glightgray -B -EJO+gblue -pdf jordan




