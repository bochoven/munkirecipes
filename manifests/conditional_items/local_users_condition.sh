#!/bin/sh
# Author: Tim Sutton
# Modified by: Arjen van Bochoven

# This condition_script supplies: 
# local_users (array): List of local usernames (not the _* accounts)

# Usage:
# To have awesome_package install only when 
# the user myadminuser is present on the machine
# use the following condition:
#
# <dict>
#	<key>condition</key>
#	<string>'myadminuser' IN local_users</string>
#	<key>managed_installs</key>
#	<array>
#		<string>awesome_package</string>
#	</array>
#</dict>

# Read the location of the ManagedInstallDir from ManagedInstall.plist
managedinstalldir="$(defaults read /Library/Preferences/ManagedInstalls ManagedInstallDir)"
# Make sure we're outputting our information to "ConditionalItems.plist" (plist is left off since defaults requires this)
plist_loc="$managedinstalldir/ConditionalItems"

# Get the list of local users, filter _* accounts
local_users=$(/usr/bin/dscl . -list /Users | grep -v ^_.*)
for user_shortname in $local_users; do
    defaults write "$plist_loc" local_users -array-add "$user_shortname"
done

# CRITICAL! Since 'defaults' outputs a binary plist, we need to ensure that munki can read it by converting it to xml
plutil -convert xml1 "$plist_loc".plist

exit 0
