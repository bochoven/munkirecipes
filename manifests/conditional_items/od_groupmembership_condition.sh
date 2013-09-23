#!/bin/sh

# This condition_script supplies: 
# assignedapps (array): list of OD groups of which this machine is a member
# Requirements:
# Install dsgrouputil in /usr/local/bin
# dsgrouputil is available from https://github.com/jatoben/dsgrouputil
# Credit: Mike Pullen

# Usage:
# -- Create OD/LDAP policy group which represent applications/packages/groups.
# --- following a namingscheme like "munkiapp_$appname" will keep policies sorted
#        and make querying policies quicker. 
#     For example:
#	-pol_comp_munkiapp_MSOffice
#	-pol_comp_munkiapp_adobecs5
#
# -- Create manifests for applications/packages/groups:
#     For example:
#       create a manifest named "_app_MSOffice" defining MSOffice for installation
#
# -- Assign applications/packages to machines by making those machines members of those groups.
# 
# -- To have the manifest "_app_MSOffice" install when a machine is member
#       of the group "-pol_comp_munkiapp_MSOffice" use the following condition:
#
# <dict>
#	<key>condition</key>
#	<string>ANY assignedapps CONTAINS 'MSOffice'</string>
#	<key>included_manifests</key>
#	<array>
#		<string>_app_MSOffice</string>
#	</array>
#</dict>
#
#


# Read the location of the ManagedInstallDir from ManagedInstall.plist
managedinstalldir="$(defaults read /Library/Preferences/ManagedInstalls ManagedInstallDir)"
# Make sure we're outputting our information to "ConditionalItems.plist" (plist is left off since defaults requires this)
plist_loc="$managedinstalldir/ConditionalItems"

# define where dsgrouputil is installed.
dsgu="/usr/local/bin/dsgrouputil"

# Gather list of all computer groups.
## If using a standardized naming scheme for munki app policy groups, the 'for' loop
##   will be quicker if $appgroups only includes munki app groups! For example:
##
##      appgroups=$( dscl /Search -list /ComputerGroups | grep munkiapp )
##
appgroups=$( dscl /Search -list /ComputerGroups ) 

# Build list of assigned applications by querying group membership of current computer 
for app in $appgroups
do
	if $dsgu -q 1 -o checkmember -t computer -currentHost 1 -g $app; then
		assignedapps+=( $app )
#		echo $assignedapps
	fi
done

# Note the key "assignedapps" which becomes the condition that you would use in a predicate statement
defaults write "$plist_loc" "assignedapps" -array "${assignedapps[@]}"

# CRITICAL! Since 'defaults' outputs a binary plist, we need to ensure that munki can read it by converting it to xml
plutil -convert xml1 "$plist_loc".plist

exit 0
