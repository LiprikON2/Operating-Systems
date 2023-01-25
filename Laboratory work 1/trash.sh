#!/usr/bin/bash

trash_folder="$HOME/.trash"
mkdir -p $trash_folder

trash_db="$trash_folder/.trash_db"
touch $trash_db

usage="
Usage: $(basename $0) [OPTIONS] [FILE]

Options:
  -h,                          Show this help menu
  -e,                          Completly erase trashed files and folders
  -l,                          List of trashed files and folders
  -r <filename>                Restore file to the current directory
"

# Handle flags
r_flag=false
for arg in $@; do
    if [ $arg == "-h" ]
    then
        echo "$usage"
        exit 0

    elif [ $arg == "-l" ]
    then
        # Read trash database file line by line
        while read line; do
            # Split the line by space into two variables
            entry_name=$(echo $line | cut -d' ' -f1)
            entry_md5=$(echo $line | cut -d' ' -f2)
            # Two variables are not empty
            if [ ! -z $entry_name ] && [ ! -z $entry_md5 ]
            then
                echo $entry_name
            fi
        done < "$trash_db"

        exit 0
        
    elif [ $arg == "-e" ]
    then
        echo $(rm -rf "$trash_folder/{*,.*}")
        echo $(rm -rf "$trash_folder/*")
        rm $trash_db

        echo "Trash folder was emptied"
        exit 0

    elif [ $arg == "-r" ]
    then
        r_flag=true

    elif [ $r_flag == true ]
    then
        # Read trash database file line by line
        while read line; do
            
            # Split the line by space into two variables
            entry_name=$(echo $line | cut -d' ' -f1)
            entry_md5=$(echo $line | cut -d' ' -f2)

            # Two variables are not empty
            if [ ! -z $entry_name ] && [ ! -z $entry_md5 ]
            then
                arg_name="$(basename -- "$arg")"

                # Handle no extension case
                if [[ $arg_name == *"."* ]]
                then
                    arg_extension=".${arg_name##*.}"
                fi
                
                # Grab the first entry with the same name
                if [ $arg_name == $entry_name ]
                then
                    # Remove entry entry from the trash database
                    echo "$(grep -v "^$line" $trash_db)" > $trash_db

                    # Restore entry
                    echo "$(mv "$trash_folder/$entry_md5$arg_extension" "./$entry_name")"
                    echo "Restored $arg entry."

                    exit 0
                fi
            fi
        done < "$trash_db"

        echo "$arg is not in the trash folder."
        exit 0
    fi
    
done

# Handle the case of a `-r` flag with missing argument
if [ $r_flag == true ]
then
    echo "-r flag was provided without argument"
    exit 0
fi

# Handle moving file or folder to the trash
for arg in $@; do
    # File
    if [ -f "$arg" ]
    then
        file_path=$(realpath $arg)
        file_md5=($(md5sum "$file_path"))

        file_name="$(basename -- "$file_path")"
        # Handle no extension case
        if [[ $file_name == *"."* ]]
        then
            file_extension=".${file_name##*.}"
        fi


        # Add entry to the trash database to store name of the file
        echo "$file_name $file_md5" >> $trash_db
        # Move file to the trash and rename it to prevent name collisions
        echo $(mv "$file_path" "$trash_folder/$file_md5$file_extension")
        echo "Moved $arg to the trash."

    # Folder
    elif [ -d "$arg" ]
    then
        folder_path=$(realpath $arg)
        # Tar the folder and get md5 of it
        folder_md5=$(tar -cf - $arg | md5sum | awk '{ print $1 }')
        
        folder_name="$(basename -- "$folder_path")"
        # Add entry to the trash database to store name of the folder
        echo "$folder_name $folder_md5" >> $trash_db
        # Move folder to the trash and rename it to prevent name collisions
        echo $(mv "$folder_path" "$trash_folder/$folder_md5")
        echo "Moved $arg to the trash."
        
    else 
        echo "$arg does not exist."
    fi
done