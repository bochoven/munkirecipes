Conditional Items
=================

Conditional items are conditions in manifests that control what part of het manifest gets executed/parsed.
Munki has a couple of built-in conditional items that are documented here: [munki/wiki/ConditionalItems](https://code.google.com/p/munki/wiki/ConditionalItems). There is also a way of providing your own items that you can test with a condition: Admin Provided Conditions.

The way *Admin Provided Conditions* work is that before the manifests are parsed, all scripts that are in `/usr/local/munki/conditions/` are executed. These scripts should add key/value pairs to `/Library/Managed Installs/ConditionalItems.plist`.
These key/value pairs are machine specific and can be used to test for certain conditions in the manifest.

The scripts in this directory contain little pieces of code that provide you with custom keys that you can use to enhance your manifests.

Each script has a Usage: paragraph that demonstrates how the condition should be used in the manifest.

Writing conditional scripts
---------------------------

* Please use the `template_condition.sh` script to write a new script. 
* Make sure your keys are unique (check the other scripts).
* Give good examples of how to use your custom condition variable.

If you have a nice conditional script that you want to share, please fork and send a pull-request.