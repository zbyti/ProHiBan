#!/bin/bash
for IMAGE in $(ls -1 *.gif)
do
    echo \*\*\* CONVERTING $IMAGE
    NAME="${IMAGE%.*}"
#    magick convert $IMAGE -brightness-contrast 20x0 -depth 2 $NAME.gray
    magick convert $IMAGE -depth 2 $NAME.gray
    python swapcolors2bpp.py $NAME.gray $NAME.gray1 0 1
    python swapcolors2bpp.py $NAME.gray1 $NAME.gray2 0 2
    python swapcolors2bpp.py $NAME.gray2 $NAME.gray3 0 3
    cp $NAME.gray3 $NAME.gfx
    rm $NAME.gray* 

done

# 0 1 2 3 
# 1 0 2 3
# 2 0 1 3
 
