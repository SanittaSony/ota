#!/bin/bash
set -x

# Check if correct number of arguments are provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <patch_directory> <original_directory> <output_directory>"
    exit 1
fi

# Check if directories exist
if [ ! -d "$1" ]; then
    echo "Error: Patch directory $1 does not exist."
    exit 1
fi

if [ ! -d "$2" ]; then
    echo "Error: Original directory $2 does not exist."
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p "$3"
mkdir -p "/data/dfota_backup"
backup_folder="/data/dfota_backup"

# Loop through all patch files in the patch directory
for patch_file in "$1"/*.patch; do
    if [ -f "$patch_file" ]; then
        filename=$(basename -- "$patch_file")
        original_file="$2/${filename%.patch}"
        output_file="/tmp/${filename%.patch}"
        md5_file="$1/${filename%.patch}.txt" # Assuming the MD5 file has the same name with .txt extension
        
        # Check if original file exists
        if [ ! -f "$original_file" ]; then
            echo "Error: Original file for $filename not found. Skipping..."
            continue
        fi
        
        # Apply patch
        echo "Applying patch for $filename..."
        bspatch "$original_file" "$output_file" "$patch_file"

        # Compute MD5 hash of the original file
        md5_actual=$(md5sum "$output_file" | awk '{print $1}')
        
        # Read MD5 hash from the MD5 file
        md5_expected=$(cat "$md5_file")
        
        # Compare MD5 hashes
        if [ "$md5_actual" != "$md5_expected" ]; then
            echo "Error: MD5 hash mismatch for $filename. Skipping..."
            continue
        fi
        # backup the original file
        mv "$original_file" "$backup_folder"

        # overwrite with the new file
        mv "$output_file" "$3"

        # if the copy successful, not interruption (eg. power loss):
        rm "$backup_folder/${filename%.patch}"
	rm "$patch_file"
	rm "$md5_file"
    fi
done

atcmd_file=$1/"atcmd"
atcmd_md5=$1/"atcmd.txt"
if [ -f "$atcmd_file" ]; then
        
    # Compute MD5 hash of the original file
    atcm_md5_actual=$(md5sum "$atcmd_file" | awk '{print $1}')
    
    # Read MD5 hash from the MD5 file
    atcm_md5_expected=$(cat "$atcmd_md5")
    
    # Compare MD5 hashes
    if [ "$atcm_md5_actual" != "$atcm_md5_expected" ]; then
        echo "Error: MD5 hash mismatch for $atcmd_file. Skipping..."
    else
        chmod +x "$atcmd_file"
        mv "$atcmd_file" "/usr/bin"
    fi
fi

echo "All patches applied successfully."
