#!/bin/bash

# Script to bulk resize, optimize, and rename only JPG/JPEG images for web.
# Requires tools like imagemagick and jpegoptim to be installed.

# Configuration
output_dir="optimized_images"
resize_percentage="30%" # Percentage to resize images (e.g., "50%")
quality_jpeg="60"      # JPEG quality (0-100, lower is more compression)
filename_prefix="img_"
counter=1
padding_length=4 # Number of digits for the counter (e.g., 3 for 001, 002)

# Ensure output directory exists
mkdir -p "$output_dir"

# Function to resize and optimize JPEG images
optimize_jpeg_rename() {
  local input="$1"
  local padded_counter=$(printf "%0${padding_length}d" "$counter")
  local output_name="${filename_prefix}${padded_counter}.jpg"
  local output_path="$output_dir/$output_name"

  echo "Processing: $input -> $output_path"

  magick "$input" -resize "$resize_percentage" "$output_path"
  if [ $? -ne 0 ]; then
    echo "Error resizing JPEG: $input"
    return 1
  fi

  jpegoptim --strip-all --max="$quality_jpeg" "$output_path"
  if [ $? -ne 0 ]; then
    echo "Error optimizing JPEG: $input"
  fi

  ((counter++))
}

# Find only JPG/JPEG image files
find . -type f \( -name "*.jpg" -o -name "*.jpeg" \) -print0 | while IFS= read -r -d $'\0' file; do
  optimize_jpeg_rename "$file"
done

echo "JPG/JPEG image optimization, resizing, and renaming complete. Optimized images are in the '$output_dir' directory."
