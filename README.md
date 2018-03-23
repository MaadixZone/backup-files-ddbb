BACK UP SCRIPT FOR DATABASES AND FILES
======================================

## Description  
 This script does a backup of all the databases and all the files from /var/www/html  
 Then it maintans copies of the newest `n` files in each folder.  
 The deletion of oldest copies is not based on file creation (date older thax XX days), but on   
 minimum number of files that have to be present in backup folder.  
 This way it ensures that `n` copies will always be present, although the backup script  
 start failing.  

 This script also includes a backup for owncloud and nextcloud data folders  
 if they exists  
 Backups are stored in $mainpath/$servername 
 You may wish to set $mainpath as needed  

 mainpath="/YOUR/PATH/HERE"
 |
 |__$mainpath/$servername/daily
               |__/ddbb
               |__/files

 |
 |__$mainpath/$servername/weekly
               |__/ddbb
               |__/files

 It's better to store copies in different folders, as this script  
 will delete older copies, leaving only newest `n` ones  
 If we put in same directory and ddbb backup fails   
 we could loose all previous ddb copies  
 This way we ensure that there will be at least `n` copies of each (ddb & files)  
 and we can set different policies for each of them  

## Requirements
root acces
Mysql


## Usage
- Place this script somwhere in your file system
- set the path in wgich you want to store the backups ($mainpath=/YOUR/CUSTOM/PATH)
- make file executable: chmod +x backup-script.sh
- Add a cronjob to run the script whenever you want. 
eg: 0 6 * * * /my/path/backup-script.sh


