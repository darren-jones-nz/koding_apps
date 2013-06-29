export DEBIAN_FRONTEND=noninteractive
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10
echo "deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen"|sudo tee /etc/apt/sources.list.d/10gen.list
sudo apt-get update
sudo apt-get -y -q install php5-dev php-pear mongodb-10gen
sudo perl -pi -e 's/^limit nofile/#limit nofile/g' /etc/init/mongodb.conf
echo "smallfiles=true" | sudo tee -a /etc/mongodb.conf
sudo apt-get install -f