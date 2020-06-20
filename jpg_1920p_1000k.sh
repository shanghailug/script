#!/bin/sh

for i in "$@"; do
    a=${i%.jpg}
    b=${a%.JPG}

    sz=2880x1920
    if [ 0`exif -t 0x0112 "$i" | grep Top-left|wc -l` = 01 ]; then
      sz=1920x2880
    fi

    c="${b}.1920p.jpg"
    convert "$i" -resize $sz -define jpeg:extent=1000kb "$c"
done

   

