#!/usr/bin/bash

# All files without `.bak` extensions
files=$(find . -maxdepth 1 -type f -not -name "*.bak")

for file in $files; do
    backup_file="${file}.bak"
    touch $backup_file

    cp $file $backup_file
done
