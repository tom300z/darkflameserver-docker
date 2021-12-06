#!/bin/bash
# Exit on error
set -e

# Ensure config files exist
for file in /default-config/*.ini; do
    if [ ! -f /config/$(basename $file) ]; then
        cp $file /config/$(basename $file)
        echo 'Recreated "/config/'$(basename $file)'" from "'$file'"'
    fi
done

# Ensure Database exists and is initialized
export MYSQL_PWD="$MYSQL_PASSWORD"
MYSQL_AUTHSTR=" --host $MYSQL_HOST -u $MYSQL_USERNAME "
RESULT=`mysql $MYSQL_AUTHSTR --skip-column-names -e "SHOW DATABASES LIKE '$MYSQL_DATABASE'"`
if [ "$RESULT" == "$MYSQL_DATABASE" ]; then
    echo 'Database "'$MYSQL_DATABASE'" exists'
else
    echo "Database does not exist"
    echo 'Creating database "'$MYSQL_DATABASE'" on host "'$MYSQL_HOST'"...'
    mysql $MYSQL_AUTHSTR -e "CREATE DATABASE $MYSQL_DATABASE"
    echo 'Initializing database...'
    for file in /db-init/*.sql; do
        echo 'Importing "'$file'"...'
        mysql $MYSQL_AUTHSTR $MYSQL_DATABASE < $file
    done
    echo 'Database "'$MYSQL_DATABASE'" initialized successfully!'
fi

# Set mysql config parameters based on evironment variables
for file in /config/*.ini; do
    sed -i "s/mysql_host.*/mysql_host=$MYSQL_HOST/g" $file
    sed -i "s/mysql_database.*/mysql_database=$MYSQL_DATABASE/g" $file
    sed -i "s/mysql_username.*/mysql_username=$MYSQL_USERNAME/g" $file
    sed -i "s/mysql_password.*/mysql_password=$MYSQL_PASSWORD/g" $file
    echo "Updated database settings in \"$file\" from environment vars"
done

# Run the DLU Server
./MasterServer

