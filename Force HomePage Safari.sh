#!/bin/sh

# SetHomepages.sh

# This script assumes that default preference files for all three browsers have been installed
# with FUT/FEU options in Casper.

if [[ "$4" != "" ]]; then
homepage="$4" # This lets us override homepage setting via Casper Remote or policy
fi

un=`ls -l /dev/console | cut -d " " -f4`

# Loop through each user to set homepage prefs
#for user in $(ls /Users | grep -v Shared | grep -v npsparcc | grep -v ".localized"); do

 ### Safari ###

    # Use defaults command to set Safari homepage
    su - "$un" -c "defaults write /Users/$un/Library/Preferences/com.apple.Safari HomePage -string $homepage"
    su - "$un" -c "defaults write com.apple.Safari NewWindowBehavior -int 0"
    su - "$un" -c "defaults write com.apple.Safari NewTabBehavior -int 0"
    su - "$un" -c "defaults write com.apple.Safari LastSafariVersionWithWelcomePage $(cat /Applications/Safari.app/Contents/Info.plist | grep -A 1 CFBundleShortVersion | awk -F '>|<' 'NR==2 {print $3}')"
    echo "Set new Safari homepage to $homepage for $un."