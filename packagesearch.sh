#!/bin/bash

# Mimic Omarchy installer with yay.
# Requires fzf installed.

echo "Fetching package list..."

# Generate formatted package list.
package_list=$(yay -Sl | awk '
BEGIN {
    # Define color variables.
    official_color_extra = "\033[1;35m";  # Bright purple.
    official_color_core = "\033[1;31m";   # Bright red.
    official_color_multilib = "\033[0;33m";  # Orange.
    aur_color = "\033[1;34m";             # Bright blue.
    bold = "\033[1m";                     # Bold text.
    ver_color = "\033[0;32m";             # Green version.
    reset = "\033[0m";                    # Reset color.

    # Define repo colors.
    colors["extra"] = official_color_extra;
    colors["multilib"] = official_color_multilib;
    colors["aur"] = aur_color;
    colors["core"] = official_color_core;
}
{
    repo = $1;
    pkg = $2;
    ver = $3;
    
    # Set repo color.
    if (repo in colors) {
        color = colors[repo];
    } else {
        # Default official color.
        color = official_color;
    }
    
    # Print formatted line.
    print color repo reset "/" bold pkg reset " (" ver_color ver reset ")";
}')

# Use fzf for selection.
selected=$(echo "$package_list" | fzf --height=40 --multi --color=border:yellow --ansi --preview="yay -Si \$(echo {} | cut -d' ' -f1)" --prompt="Search packages: ")

# Check if selected.
if [ -z "$selected" ]; then
  echo "No package selected."
  exit 0
fi

# Extract package names.
packages=$(echo "$selected" | cut -d' ' -f1 | cut -d'/' -f2)

# Install selected packages.
yay -S $packages
