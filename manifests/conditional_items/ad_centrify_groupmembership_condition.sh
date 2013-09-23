#!/bin/sh
# Author: Heig Gregorian

# This condition_script supplies: 
# aduser_groups (array): a list of AD groups the current user is a member of.
# adcomputer_groups (array): a list of AD groups this machine is a member of.

# Requirements:
# The client should be a Centrify DC bound machine
# AD policy groups setup where this machine is a member

# Usage:
# To have awesome_package install only when this machine is a member of 
# the 'awesome_package_group' use the following condition:
#
# <dict>
#	<key>condition</key>
#	<string>awesome_package_group IN adcomputer_groups</string>
#	<key>managed_installs</key>
#	<array>
#		<string>awesome_package</string>
#	</array>
#</dict>

# Read the location of the ManagedInstallDir from ManagedInstall.plist
managedinstalldir="$(defaults read /Library/Preferences/ManagedInstalls ManagedInstallDir)"
# Make sure we're outputting our information to "ConditionalItems.plist" (plist is left off since defaults requires this)
plist_loc="$managedinstalldir/ConditionalItems"

NAME="$(echo `sudo systemsetup -getcomputername | cut -d: -f2-`)"
current_user="$(ls -la /dev/console | awk '{print $3}')"

ADuser_groups="$(adquery user "$current_user" -a 2>/dev/null | sed -e 's/^.*\///g' | tr '\n' ',')"
ADcomputer_groups="$(adquery user "$NAME" -a 2>/dev/null | sed -e 's/^.*\///g' | tr '\n' ',')"

IFS=$'\n'

for aduser_group in `adquery user "$current_user" -a 2>/dev/null | sed -e 's/^.*\///g'`; do
	aduser_groups+=( $aduser_group )
done

defaults write "$plist_loc" "aduser_groups" -array "${aduser_groups[@]}"

for adcomputer_group in `adquery user "$NAME" -a 2>/dev/null | sed -e 's/^.*\///g'`; do
	adcomputer_groups+=( $adcomputer_group )
done

defaults write "$plist_loc" "adcomputer_groups" -array "${adcomputer_groups[@]}"

# CRITICAL! Since 'defaults' outputs a binary plist, we need to ensure that munki can read it by converting it to xml
plutil -convert xml1 "$plist_loc".plist

exit 0
