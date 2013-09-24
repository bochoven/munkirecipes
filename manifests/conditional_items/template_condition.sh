#!/bin/sh

# This condition_script supplies: 
# [list the variables]

# Usage:
# To have awesome_package install only when [describe the condition(s)]
# use the following condition:
#
# <dict>
#	<key>condition</key>
#	<string>[give an example of the conditional string]</string>
#	<key>managed_installs</key>
#	<array>
#		<string>awesome_package</string>
#	</array>
#</dict>

# Read the location of the ManagedInstallDir from ManagedInstall.plist
managedinstalldir="$(defaults read /Library/Preferences/ManagedInstalls ManagedInstallDir)"
# Make sure we're outputting our information to "ConditionalItems.plist" (plist is left off since defaults requires this)
plist_loc="$managedinstalldir/ConditionalItems"

[add your awesome code here]

# CRITICAL! Since 'defaults' outputs a binary plist, we need to ensure that munki can read it by converting it to xml
plutil -convert xml1 "$plist_loc".plist

exit 0
