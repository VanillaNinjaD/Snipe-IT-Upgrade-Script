#!/bin/bash -v
#
# THIS SCRIPT ONLY WORKS FOR SNIPE-IT v3.0 AND BEYOND
#
# THIS PULLS THE LATEST VERSION OF SNIPE-IT FROM MASTER, CREATES A BACKUP OF THE CURRENT SNIPE-IT DIRECTORY, AND INSTALLS
#
# REMEMBER TO SET VARIABLES BEFORE FIRST RUN

WEBSERVICENAME="apache2"
WEBSERVERUSER="www-data"
WEBSERVERDIRECTORY="/var/www/"
SNIPEITDIRECTORY="snipeit"
COMPOSERPATH="/usr/local/bin/composer"

# START SCRIPT
if [ -a master.zip ]
  then
    rm master.zip
fi
wget -c https://github.com/snipe/snipe-it/archive/master.zip
unzip master.zip
service $WEBSERVER stop
mv $WEBSERVERDIRECTORY/$SNIPEITDIRECTORY/ "$WEBSERVERDIRECTORY/snipeit_old_$(date +%F_%R)/"
BACKUPDIR=$(ls -td $WEBSERVERDIRECTORY/snipeit_old*/ | head -1)
mv snipe-it-master/ $WEBSERVERDIRECTORY/$SNIPEITDIRECTORY
cp $BACKUPDIR/.env $WEBSERVERDIRECTORY/$SNIPEITDIRECTORY/
rsync -r $BACKUPDIR/vendor/ $WEBSERVERDIRECTORY/$SNIPEITDIRECTORY/vendor/
chown -R $WEBSERVERUSER:$WEBSERVERUSER $WEBSERVERDIRECTORY/$SNIPEITDIRECTORY
cd $WEBSERVERDIRECTORY/$SNIPEITDIRECTORY/
sudo -u $WEBSERVERUSER php $COMPOSERPATH install --no-dev --prefer-source
sudo -u $WEBSERVERUSER php $COMPOSERPATH dump-autoload
php artisan migrate --force -n
php artisan config:clear
cd $WEBSERVERDIRECTORY
rsync -r $BACKUPDIR/storage/app/backups/ $SNIPEITDIRECTORY/storage/app/backups/
rsync -r $BACKUPDIR/storage/private_uploads/ $SNIPEITDIRECTORY/storage/private_uploads/
rsync -r $BACKUPDIR/public/uploads/ $SNIPEITDIRECTORY/public/uploads/
service $WEBSERVICENAME start
