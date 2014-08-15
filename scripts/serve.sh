#!/usr/bin/env bash

block="server {
    listen 80;
    server_name $1;
    root $2;

    index index.html index.htm index.php;

    charset utf-8;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    access_log off;
    error_log  /var/log/nginx/$1-error.log error;

    error_page 404 /index.php;

    sendfile off;

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/var/run/php5-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }
}
"


echo " "
echo "*******************************************"
echo "****    $1    ****"
echo "*******************************************"

echo "$block" > "/etc/nginx/sites-available/$1"
ln -fs "/etc/nginx/sites-available/$1" "/etc/nginx/sites-enabled/$1"

cd "$2/../"

# If the vendor folder doesn't exist yet,
# run composer install to set things up
vendor_dir="$2/../vendor"
if [ ! -d "$vendor_dir" ]; then
    echo "... running composer install, this may take a few minutes"
    {
        composer install
    } &> /dev/null
fi

if [[ $3 ]]; then
    # this will only get run if a dbname was passed as a third parameter
    queue="[program:$3]
command=php $2/../artisan queue:listen
directory=$2
stdout_logfile=$2/../app/storage/logs/myqueue_supervisord.log
redirect_stderr=true"
    echo "$queue" > "/etc/supervisor/conf.d/$3.conf"

    sudo supervisorctl reread
    sudo supervisorctl add $3
    sudo supervisorctl start $3
    echo "Beanstalk queue created and supervised";

    echo "CREATE USER '$3'@'localhost' IDENTIFIED BY 'secret'" | mysql -u homestead -psecret;
    echo "CREATE DATABASE IF NOT EXISTS $3" | mysql -u homestead -psecret;
    echo "Granting permisisons on $3..."
    echo "GRANT ALL PRIVILEGES ON $3.* TO '$3'@'localhost' IDENTIFIED BY 'secret'" | mysql -u homestead -psecret;
    echo "$3 DATABASE SETUP";
    echo "Database and user created";
    php artisan migrate --seed;
fi

cd /vagrant

service nginx reload
