# SimpleWallCustomListImport
Powershell tool to import some blocked ips into the user filter list using the profile.xml

Known Limitations
- Only works on Win64. If you want to use it on Win32, you need to change the version of cidr-merger which is retrieved.
- Only work on installed version, not standalone. Profile.xml not stored at the same spot


External Sources:

- Block list : https://github.com/stamparm/ipsum
- CIDR-Merger: https://github.com/zhanhb/cidr-merger

Use: 

- Launch the script, it will modify the profile.xml located in %Appdata%\Henry++\simplewall (wont work with the standalone version at the moment)
- Once it is done, use the Simplewall interface and refresh the list. It can take a little time to update the filter (check bottom left of the simplewall window for status)


!!!!WARNING!!!!!! It saves the previous profile.xml but it will be overwritten the next time it is used. It will remove your user filter list! The last save file is in the profile folder ( %Appdata%\Henry++\simplewall)
