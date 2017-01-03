#!/bin/bash

#-----------------------
# DEFINE VARIABLES HERE
#-----------------------
WEBSERVICENAME="apache2"
WEBSERVERUSER="www-data"
WEBSERVERDIRECTORY="/var/www/"
SNIPEITDIRECTORY="snipeit"
COMPOSERPATH="/usr/local/bin/composer"
MYSQLDUMPPATH="/usr/bin/mysqldump"
DBNAME="snipeit"
DBUSER="**USERNAME**"
DBPASS="**PASSWORD**"

#----------------
# PERFORM CHECKS
#----------------
if [[ $EUID -ne 0 ]]; then
   echo "THIS SCRIPT MUST BE RUN AS ROOT!!!" 1>&2
   exit 1
fi
if [ -a master.zip ]
  then
    rm master.zip
fi

#--------------
# START SCRIPT
#--------------
wget -c https://github.com/snipe/snipe-it/archive/master.zip
unzip master.zip
service $WEBSERVICENAME stop
$MYSQLDUMPPATH -u $DBUSER -p$DBPASS $DBNAME > "$WEBSERVERDIRECTORY/$SNIPEITDIRECTORY/$DBNAME.$(date +%F_%R).bak"
mv $WEBSERVERDIRECTORY/$SNIPEITDIRECTORY/ "$WEBSERVERDIRECTORY/$SNIPEITDIRECTORY.$(date +%F_%R)/"
BACKUPDIR=$(ls -td $WEBSERVERDIRECTORY/$SNIPEITDIRECTORY*/ | head -1)
mv snipe-it-master/ $WEBSERVERDIRECTORY/$SNIPEITDIRECTORY
cp $BACKUPDIR/.env $WEBSERVERDIRECTORY/$SNIPEITDIRECTORY/
rsync -r $BACKUPDIR/vendor/ $WEBSERVERDIRECTORY/$SNIPEITDIRECTORY/vendor/
chown -R $WEBSERVERUSER:$WEBSERVERUSER $WEBSERVERDIRECTORY/$SNIPEITDIRECTORY
cd $WEBSERVERDIRECTORY/$SNIPEITDIRECTORY/
sudo -u $WEBSERVERUSER php $COMPOSERPATH install --no-dev --prefer-source
sudo -u $WEBSERVERUSER php $COMPOSERPATH dump-autoload
php artisan migrate --force -n
php artisan config:clear
php artisan config:cache
cd $WEBSERVERDIRECTORY
rsync -r $BACKUPDIR/storage/app/backups/ $SNIPEITDIRECTORY/storage/app/backups/
rsync -r $BACKUPDIR/storage/private_uploads/ $SNIPEITDIRECTORY/storage/private_uploads/
rsync -r $BACKUPDIR/public/uploads/ $SNIPEITDIRECTORY/public/uploads/
service $WEBSERVICENAME start
