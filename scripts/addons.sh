echo "******************************************"
echo "************** ADDONS ********************"
echo "******************************************"

echo "** XDEBUG CONFIG **"

xdebug="
xdebug.remote_enable = 1
xdebug.remote_connect_back = 1
xdebug.remote_port = 9000
xdebug.scream=0
xdebug.cli_color=1
xdebug.show_local_vars=1
"
sudo echo "$xdebug" >> "/etc/php5/fpm/conf.d/20-xdebug.ini"

echo "** INSTALLING MAILCATCHA **"
sudo apt-get install ruby1.9.1-dev -y
sudo apt-get install libsqlite3-dev
sudo gem install mailcatcher
sudo mailcatcher --ip=192.168.33.10

# sudo apt-get install php5-dev
# sudo apt-get install php-pear

echo "** INSTALLING OAUTH **"
sudo pecl install oauth

oauth="
extension=oauth.so
"
sudo echo "$oauth" >> "/etc/php5/cli/php.ini"


echo "** RESTARTING THINGS **"
service nginx restart
service php5-fpm restart
