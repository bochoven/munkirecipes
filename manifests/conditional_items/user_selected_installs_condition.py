#!/usr/bin/python
# Author: Heig Gregorian

# This condition_script supplies: 
# selfserve_installs (array): List of user-selected optional installs
# selfserve_uninstalls (array): List of user-selected optional uninstalls

# Usage:
# To have awesome_package install only when the user selects package_x for
# installation (could also be done with requires)
# use the following condition:
#
# <dict>
#   <key>condition</key>
#   <string>ANY selfserve_installs MATCHES 'package_x'</string>
#   <key>managed_installs</key>
#   <array>
#       <string>awesome_package</string>
#   </array>
#</dict>

import os
import plistlib

from Foundation import CFPreferencesCopyAppValue

# Read the location of the ManagedInstallDir from ManagedInstall.plist
BUNDLE_ID = 'ManagedInstalls'
pref_name = 'ManagedInstallDir'
managedinstalldir = CFPreferencesCopyAppValue(pref_name, BUNDLE_ID)
selfservepath = os.path.join(managedinstalldir, 'manifests', 'SelfServeManifest')

# Make sure we're outputting our information to "ConditionalItems.plist"
conditionalitemspath = os.path.join(managedinstalldir, 'ConditionalItems.plist')

if os.path.exists(selfservepath):
    try:
        selfservemanifest = plistlib.readPlist(selfservepath)
    except Exception:
        # unable to read SelfServeManifest
        exit(0)

if selfservemanifest:
    selfserve_dict = dict(
        selfserve_installs = selfservemanifest.get('managed_installs', None),
        selfserve_uninstalls = selfservemanifest.get('managed_uninstalls', None),
    )
    if os.path.exists(conditionalitemspath):
        # "ConditionalItems.plist" exists, so read it FIRST (existing_dict)
        existing_dict = plistlib.readPlist(conditionalitemspath)
        # Create output_dict which joins new data generated in this script with existing data
        output_dict = dict(existing_dict.items() + selfserve_dict.items())
    else:
        # "ConditionalItems.plist" does not exist,
        # output only consists of data generated in this script
        output_dict = selfserve_dict

    # Write out data to "ConditionalItems.plist"
    plistlib.writePlist(output_dict, conditionalitemspath)


exit(0)