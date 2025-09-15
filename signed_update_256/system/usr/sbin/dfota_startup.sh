#!/bin/bash
set -x
# FW folders

fw_folder="/firmware/image"
backup_folder="/data/dfota_backup"
dfota_folder="/data/patches"

if [ ! -d "$backup_folder" ]; then
	echo "Error: Backup folder $backup_folder does not exist."
	exit 1
fi

# Check if patches folder exists
if [ ! -d "$dfota_folder" ]; then
	echo "Error: Patches folder $dfota_folder does not exist."
	exit 1
fi


apply_patch() {
    local fname="$1"
	local bkfile="$2"
	local patchfile="$3"
	local output_file="/tmp/${fname}"
	local md5_file="$4"
   
        
	# Check if original file exists
	if [ ! -f "$bkfile" ]; then
		echo "Error: Original BK file for $fname not found. Skipping..."
		return
	fi

	# Apply patch
	echo "Applying patch for $fname..."
	bspatch "$bkfile" "$output_file" "$patchfile"

	# Compute MD5 hash of the original file
	local md5_actual=$(md5sum "$output_file" | awk '{print $1}')

	# Read MD5 hash from the MD5 file
	local md5_expected=$(cat "$md5_file")

	# Compare MD5 hashes
	if [ "$md5_actual" != "$md5_expected" ]; then
		echo "Error: MD5 hash mismatch for $fname. Skipping..."
		return
	fi

	# Overwrite with the new file
	mv "$output_file" "${fw_folder}"

}

# Loop through all patch files in the patch directory
mount -o remount,rw roofs /
mount -o remount,rw roofs /firmware 

for fw_file in "$fw_folder"/*; do
    if [ -f "$fw_file" ]; then
        filename=$(basename -- "$fw_file")
        backup_file="$backup_folder/${filename}"
		patch_file="$dfota_folder/${filename}.patch"
        md5_file="$dfota_folder/${filename}.txt" # Assuming the MD5 file has the same name with .txt extension
		
		if [ ! -f "$patch_file" ]; then
			echo "Error: patch file does not exist."
			continue
		fi
        # Compute MD5 hash of the original file
        md5_actual=$(md5sum "$fw_file" | awk '{print $1}')

        # Read MD5 hash from the MD5 file
        md5_expected=$(cat "$md5_file")

        # Compare MD5 hashes
        if [ "$md5_actual" = "$md5_expected" ]; then
            echo "MD5 hash match for $filename. Skipping..."
            continue
        fi
        # backup the original file
		echo "MD5 hash mismatch for $filename. Apply patch..."
        
		if [ ! -f "$backup_file" ]; then
			echo "No backup file."
			apply_patch "$filename" "$fw_file" "$patch_file" "$md5_file"
		else
			echo "Has backup file."
			apply_patch "$filename" "$backup_file" "$patch_file" "$md5_file"
		fi
	fi
done


atcmd_file=$dfota_folder/"atcmd"
atcmd_md5=$dfota_folder/"atcmd.txt"
if [ -f "$atcmd_file" ]; then
        
    # Compute MD5 hash of the original file
    atcm_md5_actual=$(md5sum "/usr/bin/atcmd" | awk '{print $1}')
    
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


mount -o remount,ro roofs /

echo "All patches applied successfully."
