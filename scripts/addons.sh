# NB This file should only be used for configuring a new box

echo "******************************************"
echo "************** ADDONS ********************"
echo "******************************************"

echo "** XDEBUG CONFIG **"

xdebug="
xdebug.remote_enable = on
xdebug.remote_connect_back = on
xdebug.idekey = 'vagrant'
"
sudo echo "$xdebug" >> "/etc/php5/mods-available/xdebug.ini"

echo "** INSTALLING MAILCATCHA **"
sudo apt-get install ruby1.9.1-dev -y
sudo apt-get install libsqlite3-dev
sudo gem install mailcatcher

echo "** INSTALLING OAUTH **"
sudo pecl install oauth

oauth="
extension=oauth.so
"
sudo echo "$oauth" >> "/etc/php5/cli/php.ini"
sudo echo "$oauth" >> "/etc/php5/fpm/php.ini"

echo "** RESTARTING THINGS **"
service php5-fpm restart
service nginx restart
