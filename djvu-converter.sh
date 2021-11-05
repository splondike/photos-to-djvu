#!/bin/bash

# Script for turning a directory of scans into a single DJVU file
threshold_script="$(dirname $0)/threshold.py"

output_file=$1
if echo $output_file | grep -v -q '.djvu$';then
    echo "First argument should be a .djvu output file"
    exit 1
fi
shift

for file in "$@";do
    pgm_file=$(mktemp -u).pgm
    mogrify -format pgm -write $pgm_file "$file"
    pbm_file=$(mktemp -u).pbm
    python $threshold_script $pgm_file $pbm_file
    cleaned_pbm_file=$(mktemp -u).pbm
    unpaper --no-deskew $pbm_file $cleaned_pbm_file
    djvu_file=$(mktemp -u).djvu
    cjb2 -clean $cleaned_pbm_file $djvu_file
    if [ -f $output_file ];then
        djvm -insert $output_file $djvu_file
        rm $djvu_file
    else
        mv $djvu_file $output_file
    fi

    rm $cleaned_pbm_file
    rm $pbm_file
    rm $pgm_file
done
