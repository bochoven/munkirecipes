#!/bin/sh

# This condition_script supplies: 
# assignedapps (array): list of OD groups this machine is a member of
# Credit: Mike Pullen

# Usage:
# You need to set up your OD/LDAP with computergroups which represent
# an application/package/group. 
# To assign a certain application/package to a machine, make the machine member
# of that group.
# To have awesome_package install only when machine is member of group
# use the following condition:
#
# <dict>
#	<key>condition</key>
#	<string>awesome_package_app IN assignedapps</string>
#	<key>managed_installs</key>
#	<array>
#		<string>awesome_package</string>
#	</array>
#</dict>

# Read the location of the ManagedInstallDir from ManagedInstall.plist
managedinstalldir="$(defaults read /Library/Preferences/ManagedInstalls ManagedInstallDir)"
# Make sure we're outputting our information to "ConditionalItems.plist" (plist is left off since defaults requires this)
plist_loc="$managedinstalldir/ConditionalItems"

# define where dsgrouputil is installed. dsgrouputil is available from https://github.com/jatoben/dsgrouputil
dsgu="/usr/local/bin/dsgrouputil"

# Gather list of all computer groups.
appgroups=$( dscl /Search -list /ComputerGroups )

# Build list of assigned applications by querying group membership of current computer 
for app in $appgroups
do
	if $dsgu -q 1 -o checkmember -t computer -currentHost 1 -g $app; then
		assignedapps+=( $app )
		echo $assignedapps
	fi
done

# Note the key "assignedapps" which becomes the condition that you would use in a predicate statement
defaults write "$plist_loc" "assignedapps" -array "${assignedapps[@]}"

# CRITICAL! Since 'defaults' outputs a binary plist, we need to ensure that munki can read it by converting it to xml
plutil -convert xml1 "$plist_loc".plist

exit 0