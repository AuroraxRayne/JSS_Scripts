#!/bin/sh


# This script assumes that default preference files for all three browsers have been installed
# with FUT/FEU options in Casper.

if [[ "$4" != "" ]]; then
homepage="$4" # This lets us override homepage setting via Casper Remote or policy
fi

un=`ls -l /dev/console | cut -d " " -f4`


    # Define Firefox Profile directory to reference
    firefoxProfilesDir="/Users/$un/Library/Application Support/Firefox/Profiles"

    # Since there may be multiple profile dirs, loop through each
    for firefoxProfile in $(ls "$firefoxProfilesDir"); do

    # If there's already a homepage set, remove it
    if [[ $(grep -cw 'user_pref("browser.startup.homepage",' "$firefoxProfilesDir"/"$firefoxProfile"/prefs.js) -eq 1 ]]; then
    sed -i '' '/"browser.startup.homepage",/d' "$firefoxProfilesDir"/"$firefoxProfile"/prefs.js
    echo "Deleted old Firefox homepage for $un."
    fi

    # Add the new homepage
    echo "user_pref(\"browser.startup.homepage\", \"$homepage\");" >> "$firefoxProfilesDir"/"$firefoxProfile"/prefs.js
    echo "Set new Firefox homepage to $homepage for $un."

    done


### Safari ###

    # Use defaults command to set Safari homepage
    su - "$un" -c "defaults write com.apple.Safari HomePage $homepage"
    su - "$un" -c "defaults write com.apple.Safari NewWindowBehavior -int 0"
    su - "$un" -c "defaults write com.apple.Safari NewTabBehavior -int 0"
    su - "$un" -c "defaults write com.apple.Safari LastSafariVersionWithWelcomePage $(cat /Applications/Safari.app/Contents/Info.plist | grep -A 1 CFBundleShortVersion | awk -F '>|<' 'NR==2 {print $3}')"
    echo "Set new Safari homepage to $homepage for $un."


### Chrome ###

    # Define some variables
    chromePrefs="/Users/$un/Library/Application Support/Google/Chrome/Default/Preferences"
    sessionLines=$(awk '/session/ {print NR}' "$chromePrefs" | tail -1)
    urlLineNum=$(awk '{print NR,$0}' "$chromePrefs" | grep -A 10 "$sessionLines" | awk '/"startup_urls"/ {print $1}' | awk 'NR==1')
    urlNewLine='"startup_urls": [ '\"${homepage}\"' ]'

    # Set homepage if no homepage is set yet
    if [[ $urlLineNum == "" ]]; then
    sed -i '' '/restore_on_startup/d' "$chromePrefs"
    sed -i '' '/startup_urls_migration_time/d' "$chromePrefs"
    sed -i '' "${sessionLines}"'a\ "restore_on_startup": 4,\ "startup_urls": [ "HOMEPAGE_REPLACE" ]\' "$chromePrefs"
    sed -i '' "s/HOMEPAGE_REPLACE/$homepage/g" "$chromePrefs"
    echo "No Chrome homepage already set. Set new Chrome homepage to $homepage for $un."

    # Set homepage if there's already one set
    else
    sed -i '' "${urlLineNum}s/.*/${urlNewLine}/g" "$chromePrefs"
    sed -i '' '/startup_urls_migration_time/d' "$chromePrefs"
    echo "A Chrome homepage already set. Set new Chrome homepage to $homepage for $un."
    fi



