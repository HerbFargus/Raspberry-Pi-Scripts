#!/bin/bash

# This will copy a file into all subdirectories of the working folder

for i in *
    do
        if [ -d "$i" ]
            then
                cp yourfiletocopy.txt "$i"
        fi
    done
