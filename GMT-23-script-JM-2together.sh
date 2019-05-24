#!/bin/sh
# Purpose: Facetted plot (two maps together).
# GMT modules: gmtset, gmtdefaults, gmtinfo, gmtconvert, xyz2grd, grdcontour, pscoast, nearneighbor, pstext, gmtlogo, psconvert
# Step-1. Generate a file
ps=GMT_TWO_KKT.ps
# Step-2. GMT set up
gmt set FORMAT_GEO_MAP=dddF \
    MAP_FRAME_PEN dimgray \
    MAP_FRAME_WIDTH 0.1c \
    MAP_TITLE_OFFSET 0.2c \
    MAP_ANNOT_OFFSET 0.1c \
    MAP_TICK_PEN_PRIMARY thinner,dimgray \
    MAP_GRID_PEN_PRIMARY thinner,dimgray \
    MAP_GRID_PEN_SECONDARY thinnest,dimgray \
    FONT_TITLE 10p,Palatino-Roman,black \
    FONT_ANNOT_PRIMARY 6p,Palatino-Roman,dimgray \
    FONT_LABEL 6p,Palatino-Roman,dimgray \
# Step-3. Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults
# Step-4. Download data:
### http://topex.ucsd.edu/cgi-bin/get_data.cgi
## E-144-162;N40-51.
# Step-5. Examine the table
gmt info topo_KKT.xyz
# output: N = 1023707    <144.0083/162.0083>    <39.9976/50.9968>    <-9677/2143>
# Step-6. Convert ASCII to binary
gmt convert topo_KKT.xyz -bo > topo_KKT.b
# Step-7. Gridding using xyz2grd technique.
gmt xyz2grd topo_KKT.xyz -Gxyz2grdKKT.nc -R144/162/40/51 -I5m -Vv
#
# 1st PLOT (left)
#
# Step-8. Add contour lines
gmt grdcontour xyz2grdKKT.nc -R144/40/162/51r -JM7.5c -C1000 -A2000 -Gd2i -P -K > $ps
# Step-9. Add coastline
gmt pscoast -R -J \
    -Bpxg2f2a4 -Bpyg2f2a4 -Bsxg2 -Bsyg2 -Df -Wthinnest \
    -B+t"XYZ2grd GMT module" \
    -TdjBR+w0.4i+l+o0.15i \
    -Lx14c/-1.3c+c50+w500k+l"Mercator projection, Scale, km"+f \
    -UBL/-15p/-45p -O -K >> $ps
#
# 2nd PLOT (right)
#
# Step-10. Gridding using a nearest neighbor technique.
region=`gmt info topo_KKT.b -I1 -bi3d`
gmt nearneighbor $region -I10m -S40k -Gtopo_NN_KKT.nc topo_KKT.b -bi
# Step-11. Add contour lines
gmt grdcontour topo_NN_KKT.nc -R144/40/162/51r -JM7.5c -X3.6i -C1000 -A2000 -Gd2i -O -K >> $ps
# Step-12. Add coastline
gmt pscoast -R -J \
    -Bpxg2f2a4 -Bpyg2f2a4 -Bsxg2 -Bsyg2 -Df -Wthinnest \
    -B+t"Nearest neighbor algorithm" \
    -TdjBR+w0.4i+l+o0.15i \
    -Lx13.5c/-1.3c+o1.0c/0c+c50+w400k+l"Mercator projection, Scale, km"+f \
    -O -K >> $ps
#
# Step-13. Add captions: a) and b)
gmt pstext -R0/10/0/10 -Jx1c -F+f12p,Palatino-Bold+jCB -O -K -N >> $ps << END
-0.5 7.3 b)
-10.5 7.3 a)
END
# Step-14. Add common title
gmt pstext -R0/10/0/10 -Jx1c -F+f14p,Palatino-Bold+jCB -O -K -N >> $ps << FIN
0.1 8.0 Gridding using various algorithm approaches
FIN
# Step-15. Add GMT logo
gmt logo -R0/10/0/10 -Jx1c -Dx0.0c/0.0c+o-2.0c/-2.0c+w2c -O >> $ps
# Step-16. Convert to image file using GhostScript (portrait orientation, 720 dpi)
gmt psconvert GMT_TWO_KKT.ps -A0.2c -E720 -Tj -P -Z
