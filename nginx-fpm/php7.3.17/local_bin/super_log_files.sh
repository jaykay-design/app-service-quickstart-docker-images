#!/bin/sh

while [ 1 ]
do 
    if [ -e /run/php/php-fpm.sock ]; then
        #echo "exist...chmod... "
        chmod 777 /run/php/php-fpm.sock                      
    else            
        echo "INFO: It's not ready..."                        
    fi
    if test ! -e $NGINX_LOG_DIR/access.log; then 
        touch $NGINX_LOG_DIR/access.log
    fi
    if test ! -e $NGINX_LOG_DIR/error.log; then 
        touch $NGINX_LOG_DIR/error.log
    fi
    if [ ! -e "$NGINX_LOG_DIR/php-error.log" ]; then    
        touch $NGINX_LOG_DIR/php-error.log;    
    fi
    if [ ! -e "$SUPERVISOR_LOG_DIR/supervisord.log" ]; then    
        touch $SUPERVISOR_LOG_DIR/supervisord.log;    
    fi
    chmod 666 $NGINX_LOG_DIR/access.log
    chmod 666 $NGINX_LOG_DIR/error.log
    chmod 666 $NGINX_LOG_DIR/php-error.log
    chmod 666 $SUPERVISOR_LOG_DIR/supervisord.log
    test ! -d "/home/LogFiles/olddir" && echo "INFO: Log folder for nginx/php not found. creating..." && mkdir -p "/home/LogFiles/olddir"
    sleep 3s
done 
