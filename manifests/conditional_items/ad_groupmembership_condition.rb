#!/usr/bin/env ruby
# Author: Joseph Rafferty

# This condition_script supplies: 
# directory_groups (array): List of AD groups this machine is a member of.

# Requirements:
# The client should be a AD bound machine
# AD policy groups setup where this machine is a member

# Usage:
# To have awesome_package install only when this machine is a member of 
# the 'awesome_package_group' use the following condition:
#
# <dict>
# <key>condition</key>
# <string>awesome_package_group IN directory_groups</string>
# <key>managed_installs</key>
# <array>
#   <string>awesome_package</string>
# </array>
#</dict>

ComputerName = `scutil --get ComputerName`.strip
ADGroupAttribute = 'dsAttrTypeNative:memberOf'
GroupAttributeSeparator = /\s*(?=CN=)/
PlistGroupKey = 'directory_groups'

ManagedInstallDir=`defaults read /Library/Preferences/ManagedInstalls ManagedInstallDir`.strip
PlistLocation = File.join( "#{ManagedInstallDir}", "Conditionalitems" )
 
unless ComputerName.empty?
  # Read the LDAP attribute that lists which groups our computer object is a member of
  groups_string = `dscl /Search read /Computers/#{ComputerName}$ #{ADGroupAttribute}`
  puts groups_string
  unless groups_string.empty?
    # Split the listed groups into an array (and remove the ldap attribute prefix)
    groups = groups_string.split(GroupAttributeSeparator).collect{|g| g if g.chomp(':') != ADGroupAttribute}.compact
    
    # Shorten the group names from the distinguished name to just the group name
    groups.collect!{|g| "'#{g[/([^,])*/].gsub("CN=", "").downcase}'" } # use a substitution to remove CN=, system ruby 1.8.7 regex doesn't support lookbehinds
    
    if groups.length.zero?
      puts "No directory groups to list. Skipping setting preferences"
    else
      my_routine = Proc.new { |str| str.upcase }
      puts "The following directory groups will be written to the #{PlistGroupKey} key: #{groups.join(' ')}"
      puts `defaults write \"#{PlistLocation}\" #{PlistGroupKey} -array #{groups.join(' ')}`
    end
    
    `plutil -convert xml1 \"#{PlistLocation}.plist\"`
    `chmod 0644 \"#{PlistLocation}.plist\"`
    
  end
else
  puts "Could not obtain computer name!"
end