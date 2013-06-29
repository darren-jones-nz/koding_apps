sudo pecl install mongo
echo "extension=mongo.so" | sudo tee -a /etc/php5/apache2/php.ini