# Remove all MECM clients from specified Device Collections
 This script connects to your ConfigMgr site, search for any provided device collection names, and systematically remove any and all clients from them. 
 Useful when you have collections that you only need clients added to temporarily, and don't want to manually remove them all afterwards.

 ## Config File
 Rename the config.json.example to **config.json** 
 Update the two key values according to your environment

 ## Array of Device Collections
 In the script, enter the device collections which you want all clients removed from
