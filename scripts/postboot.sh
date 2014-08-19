# Start mailcatcher
sudo mailcatcher --ip=192.168.33.10
# sudo service supervisor start

echo " "
echo "***************************"
echo "Setup complete, restarting"
service nginx restart
service php5-fpm restart

echo "... now get to work"
