#!/bin/bash -v
pwd
if [ -a master.zip ]
  then
    rm master.zip
fi
wget -c https://github.com/snipe/snipe-it/archive/master.zip
unzip master.zip
service apache2 stop
mv /var/www/snipeit/ "/var/www/snipeit_old_$(date +%F_%R)/"
BACKUPDIR=$(ls -td /var/www/snipeit_old*/ | head -1)
mv snipe-it-master/ /var/www/snipeit
cp $BACKUPDIR/.env /var/www/snipeit/
rsync -r $BACKUPDIR/vendor/ /var/www/snipeit/vendor/
chown -R www-data:www-data /var/www/snipeit
cd /var/www/snipeit/
sudo -u www-data php /usr/local/bin/composer install --no-dev --prefer-source
sudo -u www-data php /usr/local/bin/composer dump-autoload
php artisan migrate --force -n
php artisan config:clear
cd /var/www/
rsync -r $BACKUPDIR/storage/app/backups/ snipeit/storage/app/backups/
rsync -r $BACKUPDIR/storage/private_uploads/ snipeit/storage/private_uploads/
rsync -r $BACKUPDIR/public/uploads/ snipeit/public/uploads/
service apache2 start
