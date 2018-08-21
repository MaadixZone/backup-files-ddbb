#!/bin/bash -x

## DAILY BACKUP ##
# This script does a backup of all the databases and all the files from /var/www/html
# Then it maintans copies of the newest `n` files in each folder.
# The deletion of oldest copies is not based on file creation (date older thax XX days), but on 
# minimum number of files that have to be present in backup folder.
# This way it ensures that `n` copies will always be present, although the backup script
# start failing.
# This script also includes a backup for owncloud and nextcloud data folders
# if they exists
# Backups are stored in $mainpath/$servername 
# You may wish to set $mainpath as needed
# mainpath="/YOUR/PATH/HERE"
# |
# |__$mainpath/$servername/daily
#               |__/ddbb
#               |__/files
#
# |
# |__$mainpath/$servername/weekly
#               |__/ddbb
#               |__/files
#
# It's better to store copies in different folders, as this script
# will delete older copies, leaving only newest `n` ones
# If we put in same directory and ddbb backup fails 
# we could loose all previous ddb copies
# This way we ensure that there will be at least `n` copies of each (ddb & files)
# and we can set different policies for each of them

#Backup dirs
## If backup directories do not exists , let's create them
servername="$(hostname)"
#Change this with the path you want the backups to be stores
# mainpath="/YOUR/PATH/HERE"
mainpath="/home/ansible/backups"
# username="YOUR-USER-NAME"
username="ansible"
# directory for daily databases
if [[ ! -d "$mainpath/$servername/daily/ddbb" ]]; then
  mkdir -p $mainpath/$servername/daily/ddbb
fi
# Directory for daily files backup
if [[ ! -d "$mainpath/$servername/daily/files" ]]; then
  mkdir -p $mainpath/$servername/daily/files
fi

#Directeory for weekly database backups
if [[ ! -d "$mainpath/$servername/weekly/ddbb" ]]; then
  mkdir -p $mainpath/$servername/weekly/ddbb
fi

#Directeory for weekly database backups
if [[ ! -d "$mainpath/$servername/weekly/files" ]]; then
  mkdir -p $mainpath/$servername/weekly/files
fi

#daily databases folder
bfolderddbb="$mainpath/$servername/daily/ddbb"
#daily files folder
bfolderfiles="$mainpath/$servername/daily/files"
#weekly databases folder
bfolderweeklyddbb="$mainpath/$servername/weekly/ddbb"
#weekly files folder
bfolderweeklyfiles="$mainpath/$servername/weekly/files"

#Backup all ddbb
filenamedb=allddbb_$(date +%Y-%m-%d_%H-%M).gz
mysqldump --all-databases | gzip -c > $bfolderddbb/$filenamedb
chown $username $bfolderddbb/$filenamedb
chmod 600 $bfolderddbb/$filenamedb

#Backup /var/www
filename=$servername-$(date +%Y-%m-%d_%H-%M).tar.gz
apps="/var/www/html"

# Make a copy of Owncloud and nextcloud data.
# If in the future there will be other folder to backup, outside of
# /var/www/html, add them here following same logig
ncexists=""
ocexists=""
#Check if OC and Nextcloud Data folder exists.
# If so add them to tar.gz backup file
if [ -d "/var/www/nextcloud/data" ]; then
  ncexists="/var/www/nextcloud/data/";
fi

if [ -d "/var/www/owncloud/data" ]; then
  ocexists="/var/www/owncloud/data";
fi
appsinvar="$apps $ncexists $ocexists"
tar -czf $bfolderfiles/$filename $appsinvar
chown $username $bfolderfiles/$filename
chmod 600 $bfolderfiles/$filename

## WEEKLY BACKUP ##

DAYOFWEEK=$(date +"%u")
if [ "$DAYOFWEEK" -eq 5 ];
then
  #Backup all ddbb
  cp -Rp $bfolderddbb/$filenamedb $bfolderweeklyddbb

  #Backup /var/www
  cp -Rp $bfolderfiles/$filename $bfolderweeklyfiles
fi

#Delete backups daily leaving 7 newest copies in database backup folder
# Change head -n -xxx value to increase or decrease the number of copy you want to save
if [ -d "$bfolderddbb" ]; then
  deletedailydb=$(find $bfolderddbb -type f -printf "%T@ $bfolderddbb/%f\n" | sort -n | awk '{ print $2 }' | head -n -7 | xargs rm )
fi
#Delete backups daily leaving 7 newest copies in database backup folder
if [ -d "$bfolderfiles" ]; then
  deletedailyfiles=$(find $bfolderfiles -type f -printf "%T@ $bfolderfiles/%f\n" | sort -n |  awk '{ print $2 }' | head -n -7 | xargs rm ) 
fi
#Delete files backups weekly leaving 7 newest copies 
if [ -d "$bfolderweeklyddbb" ]; then
  deletedbweek=$(find $bfolderweeklyddbb -type f -printf "%T@ $bfolderweeklyddbb/%f\n" | sort -n | awk '{ print $2 }' | head -n -7 | xargs rm )
fi
#Delete files backups weekly leaving 7 newest copies 
if [ -d "$bfolderweeklyfiles" ]; then
  deletefilesweek=$(find $bfolderweeklyfiles -type f -printf "%T@ $bfolderweeklyfiles/%f\n" | sort -n | awk '{ print $2 }' | head -n -7 | xargs rm )
fi

