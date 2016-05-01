#!/bin/bash

# this script will take all files in the current directory with the .ANI extension, create folders based on the filenames
# with the extensions stripped, and then will move each .ANI file into its matching folder that was just created.

for file in *.ANI; do
dir="${file%%.*}"
if [ -e $dir ];then
mv "$file" "$dir"
else
mkdir -p "$dir"
mv "$file" "$dir"
fi
done
