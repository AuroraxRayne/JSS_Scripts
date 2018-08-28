#!/bin/sh

#Getting Logged in Users
loggedInUser=`python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");'`

#Getting UID for loggedInUser
uid=$(id -u $loggedInUser)

KEXT_BUNDLE_IDENTIFIER="com.box.filesystems.osxfuse"
BFD_IDENTIFIER="com.box.desktop"
AUTOUPDATER_IDENTIFIER=com.box.desktop.autoupdater
AUTOUPDATER_PLIST_PATH=/Library/LaunchDaemons/$AUTOUPDATER_IDENTIFIER.plist
BOX_HELPER_IDENTIFIER=com.box.desktop.helper
BOX_HELPER_PLIST_PATH=/Library/LaunchAgents/$BOX_HELPER_IDENTIFIER.plist

#
# Return 1 if an app with the specified bundle ID is running
#
function is_app_running {
    /usr/bin/lsappinfo find kLSBundleIdentifierLowerCaseKey="$1" | grep -c ASN
}

#
# Use Spotlight to glean info on locations of Box.app
#
function number_of_box_apps_installed {
    /usr/bin/mdfind -count kMDItemCFBundleIdentifier = $BFD_IDENTIFIER
}

function path_to_first_box_app_found {
    /usr/bin/mdfind kMDItemCFBundleIdentifier = $BFD_IDENTIFIER | head -n 1
}

function number_of_box_apps_in_applications_folder {
    /usr/bin/mdfind kMDItemCFBundleIdentifier = $BFD_IDENTIFIER | grep "^/Applications/" -c
}

function box_app_exists_in_applications_folder {
	[ "$(number_of_box_apps_in_applications_folder)" -gt 0 ]
}

function path_to_box_app_in_applications_folder {
    /usr/bin/mdfind kMDItemCFBundleIdentifier = $BFD_IDENTIFIER | grep "^/Applications/" | head -n 1
}

#
# Where is box.app?
#
# - If /Applications/Box.app exists, use that
# - If Box.app exists in a sub-folder of /Applications, use that
# - If user has only one copy of Box.app on the machine, use that
#
function box_app_path {
    if [ -e "/Applications/Box.app" ]; then
        /bin/echo -n "/Applications/Box.app"
    elif box_app_exists_in_applications_folder; then
        /bin/echo -n "$(path_to_box_app_in_applications_folder)"
    elif [ "$(number_of_box_apps_installed)" -eq 1 ]; then
        /bin/echo -n "$(path_to_first_box_app_found)"
    else
        /bin/echo -n ""
    fi
}

#
# Exit the script with a message if we're not running as root
#
function ensure_running_as_root {
    if [ $EUID -ne 0 ]; then
        echo "This script must be run as root. Please use 'sudo'."
        exit 1
    fi
}

#
# Try to unload the FUSE kext. If the unload fails, tell the user to reboot
# and exit the script.
#
function unload_kext {
    local RESULT=0
    if [[ -n "$(/usr/sbin/kextstat -l -b $KEXT_BUNDLE_IDENTIFIER)" ]]
    then
        /sbin/kextunload -b $KEXT_BUNDLE_IDENTIFIER
        RESULT=$?
    fi

    if [ $RESULT -ne 0 ]; then
    	echo "Unable to unload the FUSE kext. Please reboot your machine and run this script again."
        if [ "$1" -eq 1 ]; then
    	    exit 2
    	fi
    fi

    return $RESULT
}


#
# Disable our launchDaemon and launchAgent
#
function unload_root_au_and_helper {
    /bin/launchctl unload $AUTOUPDATER_PLIST_PATH || true

    # On older versions of Box Drive the Helper wasn't properly limited to Aqua sessions only, so also remove the "root" version too
    /bin/launchctl unload $BOX_HELPER_PLIST_PATH || true
}

#
# Remove everything installed by the umbrella pkg
#
function delete_all_the_things {
    # Remove the app
    app_path=$(box_app_path)
    rm -rf "$app_path"

    # Remove AU & other system-level components and logs.
    # If top-level "Box" folders are empty, remove them too.
    rm -rf /Library/Application\ Support/Box/Box
    if [ ! "$(ls -A /Library/Application\ Support/Box)" ]; then
        rm -rf /Library/Application\ Support/Box
    fi

    rm -rf /Library/Logs/Box/Box
    if [ ! "$(ls -A /Library/Logs/Box)" ]; then
        rm -rf /Library/Application\ Support/Box
    fi

    rm -f $AUTOUPDATER_PLIST_PATH
    rm -f $BOX_HELPER_PLIST_PATH

    # Remove any user-level components and logs.
    # If top-level "Box" folders are empty, remove them too.
    # TODO: Should we do this for every user on the machine?
    rm -rf /Users/$loggedInUser/Library/Application\ Support/Box/Box
    if [ ! "$(ls -A /Users/$loggedInUser/Library/Application\ Support/Box)" ]; then
        rm -rf /Users/$loggedInUser/Library/Application\ Support/Box
    fi

    rm -rf /Users/$loggedInUser/Library/Logs/Box/Box
    if [ ! "$(ls -A /Users/$loggedInUser/Library/Logs/Box)" ]; then
        rm -rf /Users/$loggedInUser/Library/Logs/Box
    fi

    # Remove FUSE
    if [ -e /Users/$loggedInUser/Library/PreferencePanes/OSXFUSE.prefPane/ ]; then
        rm -rf /Users/$loggedInUser/Library/PreferencePanes/OSXFUSE.prefPane/
    fi
    rm -rf /Library/Filesystems/box.fs

    # Remove Finder Extension logs
    if [ -e /Users/$loggedInUser/Library/Containers/com.box.desktop.findersyncext ]; then
        rm -rf /Users/$loggedInUser/Library/Containers/com.box.desktop.findersyncext
    fi

    # Remove WebView caches
    if [ -e /Users/$loggedInUser/Library/Caches/com.box.desktop ]; then
    	rm -rf /Users/$loggedInUser/Library/Caches/com.box.desktop
    fi
    if [ -e /Users/$loggedInUser/Library/Caches/com.box.desktop.ui ]; then
    	rm -rf /Users/$loggedInUser/Library/Caches/com.box.desktop.ui
    fi
}

#
# Clear out any prefs we've set
#
function clear_system_level_prefs {
    # system-level
    /usr/bin/defaults delete com.box.desktop.autoupdater || true
    /usr/bin/defaults delete com.box.desktop.installer || true
}

#
# Remove the pkg receipts
#
# Pre-1.4 releases use "com.box.installer.sync" for the main installer; 1.4 and
# later uses com.box.installer.desktop.
#
function forget_pkg_receipts {
    /usr/sbin/pkgutil --forget com.box.desktop.installer.sync
    /usr/sbin/pkgutil --forget com.box.desktop.installer.desktop
    /usr/sbin/pkgutil --forget com.box.desktop.installer.local.appsupport
    /usr/sbin/pkgutil --forget com.box.desktop.installer.autoupdater
    /usr/sbin/pkgutil --forget com.box.desktop.installer.osxfuse
}





#Lets first kill Box Sync and Box Drive if they are running

if ( pgrep "Box" > /dev/null ); then
    echo "Killing Box"
    killall "Box"
else
    echo "Box is not running"
fi

if ( pgrep "Box Sync" > /dev/null ); then
    echo "Killing Box Sync"
    killall "Box Sync"
else
    echo "Box Sync is not running"
fi


#Lets uninstall Box App
if [[ -e "/Applications/Box.app" ]]; then
	echo "Running Box.app Uninstaller"
	/bin/launchctl unload /Library/LaunchAgents/com.box.desktop.helper.plist || true
	/usr/bin/pluginkit -e ignore -i com.box.desktop.findersyncext || true
	unload_kext 1 && \
	unload_root_au_and_helper

	# perform most of the uninstall
	delete_all_the_things
	clear_system_level_prefs
	forget_pkg_receipts
	defaults delete /Users/$loggedInUser/Library/Preferences/com.box.desktop.installer.plist || true
	defaults delete /Users/$loggedInUser/Library/Preferences/com.box.desktop.ui.plist || true
	defaults delete /Users/$loggedInUser/Library/Preferences/com.box.desktop.plist || true
	/bin/launchctl asuser "$uid" /usr/bin/osascript -e 'tell application "System Events" to delete every login item whose name is "Box"' 2>/dev/null || true
else
	echo "Box.app is not installed"
fi

#Lets clean up Box Sync files
if [[ -e "/Applications/Box Sync.app" ]]; then
	echo "Removing Box Sync Files"
	rm -rf "/Applications/Box Sync.app"
	rm -rf "/Users/$loggedInUser/Library/Logs/Box/Box Sync/"
	rm -rf "/Users/$loggedInUser/Library/Application Support/Box/Box Sync/"
	rm -rf "/Users/$loggedInUser/Library/Preferences/com.box.sync.plist"
	rm -rf "/Library/PrivilegedHelperTools/com.box.sync.bootstrapper"
	rm -rf "/Library/PrivilegedHelperTools/com.box.sync.iconhelper"
else
	echo "Box Sync is not installed"
fi
