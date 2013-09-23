#!/bin/sh

# This condition_script supplies one variable: 
# at_loginwindow (boolean): TRUE when no user logged in, FALSE when a user is logged in

# Usage:
# To have awesome_package install only when at the loginwindow,
# use the following condition:
#
# <dict>
#	<key>condition</key>
#	<string>at_loginwindow == TRUE</string>
#	<key>managed_installs</key>
#	<array>
#		<string>awesome_package</string>
#	</array>
#</dict>

# Read the location of the ManagedInstallDir from ManagedInstall.plist
managedinstalldir="$(defaults read /Library/Preferences/ManagedInstalls ManagedInstallDir)"
# Make sure we're outputting our information to "ConditionalItems.plist" (plist is left off since defaults requires this)
plist_loc="$managedinstalldir/ConditionalItems"

# Check if there is a console user
at_loginwindow='false'
# If there is no console user, set at_loginwindow to 'true'
$(test "$(ls -la /dev/console | awk '{print $3}')" = 'root') && at_loginwindow='true'

# Write key/value pair to ConditionalItems.plist
defaults write "$plist_loc" "at_loginwindow" -bool $at_loginwindow

# CRITICAL! Since 'defaults' outputs a binary plist, we need to ensure that munki can read it by converting it to xml
plutil -convert xml1 "$plist_loc".plist

exit 0
