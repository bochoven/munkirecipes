#!/bin/sh

# This condition_script supplies two variables: 
# weekday (integer): the numerical representation of the weekday (mon=1, tue=2, etc)
# time (string): the time string in the format hh:mm

# Usage:
# To have awesome_package install only on saturday or sunday, after 8PM,
# use the following condition:
#
# <dict>
#	<key>condition</key>
#	<string>weekday IN { 6, 7 } AND time &gt; "20:00"</string>
#	<key>managed_installs</key>
#	<array>
#		<string>awesome_package</string>
#	</array>
#</dict>

# Read the location of the ManagedInstallDir from ManagedInstall.plist
managedinstalldir="$(defaults read /Library/Preferences/ManagedInstalls ManagedInstallDir)"
# Make sure we're outputting our information to "ConditionalItems.plist" (plist is left off since defaults requires this)
plist_loc="$managedinstalldir/ConditionalItems"

# Get weekday and time
defaults write "$plist_loc" "weekday" -int $(date "+%u")
defaults write "$plist_loc" "time" -string $(date "+%H:%M")

# CRITICAL! Since 'defaults' outputs a binary plist, we need to ensure that munki can read it by converting it to xml
plutil -convert xml1 "$plist_loc".plist

exit 0