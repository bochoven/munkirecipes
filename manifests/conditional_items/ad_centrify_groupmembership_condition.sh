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
# the 'awesome_computers' AD group use the following condition:
#
#
# (case and diacritic insensitive)
# <key>conditional_items</key>
# <array>
# 	<dict>
#		<key>condition</key>
#		<string>ANY adcomputer_groups MATCHES[cd] 'awesome_computers'</string>
#		<key>managed_installs</key>
#		<array>
#			<string>awesome_package</string>
#		</array>
#	</dict>
# </array>

computer_name="$(echo `sudo systemsetup -getcomputername | cut -d: -f2-`)"
current_user="$(ls -la /dev/console | awk '{print $3}')"

IFS=$'\n'
aduser_groups=($(adquery user "$current_user" -a 2>/dev/null | sed -e 's/^.*\///g'))
adcomputer_groups=($(adquery user "$computer_name" -a 2>/dev/null | sed -e 's/^.*\///g'))
plist_loc="/Library/Managed Installs/ConditionalItems"


defaults write "$plist_loc" "aduser_groups" -array "${aduser_groups[@]}"
defaults write "$plist_loc" "adcomputer_groups" -array "${adcomputer_groups[@]}"
plutil -convert xml1 "$plist_loc".plist

exit 0