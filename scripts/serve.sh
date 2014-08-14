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

echo "****************************"
echo "**** SETTING UP $1 ****"
echo "****************************"

echo "$block" > "/etc/nginx/sites-available/$1"
ln -fs "/etc/nginx/sites-available/$1" "/etc/nginx/sites-enabled/$1"

echo "Configs setup, restarting"
service nginx restart
service php5-fpm restart

echo "SETTING UP DB: $3"
echo "CREATE DATABASE IF NOT EXISTS $3" | mysql -u homestead -psecret
# forge user was created in addons.sh
echo "GRANT ALL PRIVILEGES ON $3.* TO 'forge'@'localhost' IDENTIFIED BY 'secret'" | mysql -u homestead -psecret
echo "DB SETUP"
cd "$2/../"
php artisan migrate --seed --force
echo "** DATABASE SEEDED **"

cd /vagrant
