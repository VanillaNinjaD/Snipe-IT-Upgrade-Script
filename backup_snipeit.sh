#!/bin/bash

#-----------------------
# DEFINE VARIABLES HERE
#-----------------------
WEBSERVERUSER="www-data"
WEBSERVERDIRECTORY="/var/www"
SNIPEITDIRECTORY="snipeit"
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

#--------------
# START SCRIPT
#--------------
$MYSQLDUMPPATH -u $DBUSER -p$DBPASS $DBNAME > "$WEBSERVERDIRECTORY/$SNIPEITDIRECTORY/$DBNAME.$(date +%F_%R).bak"
sudo -u $WEBSERVERUSER cp -r $WEBSERVERDIRECTORY/$SNIPEITDIRECTORY/ "$WEBSERVERDIRECTORY/$SNIPEITDIRECTORY.$(date +%F_%R)/"
