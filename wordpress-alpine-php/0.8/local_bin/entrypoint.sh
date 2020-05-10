#!/bin/bash

# set -e

php -v

AZURE_DETECTED=$WEBSITES_ENABLE_APP_SERVICE_STORAGE # if defined, assume the container is running on Azure

echo "Setup openrc ..." && openrc && touch /run/openrc/softlevel

GIT_REPO=${GIT_REPO:-https://github.com/azureappserviceoss/wordpress-azure}
GIT_BRANCH=${GIT_BRANCH:-linux-appservice}
echo "INFO: ++++++++++++++++++++++++++++++++++++++++++++++++++:"
echo "REPO: "$GIT_REPO
echo "BRANCH: "$GIT_BRANCH
echo "INFO: ++++++++++++++++++++++++++++++++++++++++++++++++++:"

cd $WORDPRESS_HOME

if ! [ -e wp-config.php ]; then
    rm index.php
    echo "INFO: There in no wordpress, going to GIT clone ...:"
    git init
    git remote add origin $GIT_REPO
    git fetch 
    git checkout $GIT_BRANCH
    git branch --set-upstream-to=origin/$GIT_BRANCH $GIT_BRANCH
else
    echo "INFO: Wordpress exists, pulling changes."
    git pull
fi

# Although in AZURE, we still need below chown cmd.
chown -R nginx:nginx $WORDPRESS_HOME    

chmod 777 $WORDPRESS_SOURCE/wp-config.php
if [ ! $AZURE_DETECTED ]; then 
    echo "INFO: NOT in Azure, chown for wp-config.php"
    chown -R nginx:nginx $WORDPRESS_SOURCE/wp-config.php
fi

# setup server root
if [ ! $AZURE_DETECTED ]; then 
    echo "INFO: NOT in Azure, chown for "$WORDPRESS_HOME 
    chown -R nginx:nginx $WORDPRESS_HOME
fi

echo "Starting Redis ..."
redis-server &

if [ ! $AZURE_DETECTED ]; then	
    echo "NOT in AZURE, Start crond, log rotate..."	
    crond	
fi 

test ! -d "$SUPERVISOR_LOG_DIR" && echo "INFO: $SUPERVISOR_LOG_DIR not found. creating ..." && mkdir -p "$SUPERVISOR_LOG_DIR"
test ! -d "$NGINX_LOG_DIR" && echo "INFO: Log folder for nginx/php not found. creating..." && mkdir -p "$NGINX_LOG_DIR"
test ! -e /home/50x.html && echo "INFO: 50x file not found. createing..." && cp /usr/share/nginx/html/50x.html /home/50x.html
if [ ! -d "/home/etc/nginx" ]; then
    mkdir -p /home/etc && mv /etc/nginx /home/etc/nginx
else
    mv /etc/nginx /etc/nginx-bak
    # Is it upgrade from 0.72? 
    sed -i "s/php7.0-fpm.sock/php-fpm.sock/g" /home/etc/nginx/conf.d/default.conf
fi
ln -s /home/etc/nginx /etc/nginx


echo "INFO: creating /run/php/php-fpm.sock ..."
test -e /run/php/php-fpm.sock && rm -f /run/php/php-fpm.sock
mkdir -p /run/php
touch /run/php/php-fpm.sock
chown nginx:nginx /run/php/php-fpm.sock
chmod 777 /run/php/php-fpm.sock

sed -i "s/SSH_PORT/$SSH_PORT/g" /etc/ssh/sshd_config
echo "Starting SSH ..."
echo "Starting php-fpm ..."
echo "Starting Nginx ..."

cd /usr/bin/
supervisord -c /etc/supervisord.conf
