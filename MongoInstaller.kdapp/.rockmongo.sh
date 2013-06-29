cd ~/Web
wget http://rockmongo.com/downloads/go?id=12
mv go?id=12 ~/Web/rockmongo.zip
unzip ~/Web/rockmongo.zip -d ~/Web/
rm ~/Web/rockmongo.zip
sed -i "28d" ~/Web/rockmongo/config.php && sed -i "28i \$MONGO[\"servers\"][\$i][\"mongo_auth\"] = true;" ~/Web/rockmongo/config.php