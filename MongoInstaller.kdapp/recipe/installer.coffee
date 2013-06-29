{Settings}  = Installer
{Recipe}    = Installer.Core

files =
  mongoinstall:
    """
    export DEBIAN_FRONTEND=noninteractive
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10
    echo "deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen"|sudo tee /etc/apt/sources.list.d/10gen.list
    sudo apt-get update
    sudo apt-get -y -q install php5-dev php-pear mongodb-10gen
    sudo perl -pi -e 's/^limit nofile/#limit nofile/g' /etc/init/mongodb.conf
    echo "smallfiles=true" | sudo tee -a /etc/mongodb.conf
    sudo apt-get install -f
    """
  php:
    """
    sudo pecl install mongo
    echo "extension=mongo.so" | sudo tee -a /etc/php5/apache2/php.ini
    """
  rockmongo:
    """
    cd ~/Web
    wget http://rockmongo.com/downloads/go?id=12
    mv go\?id\=12 ~/Web/rockmongo.zip
    unzip ~/Web/rockmongo.zip -d ~/Web/
    rm ~/Web/rockmongo.zip
    sed -i "28d" ~/Web/rockmongo/config.php && sed -i "28i \\\$MONGO[\\\"servers\\\"][\\\$i][\\\"mongo_auth\\\"] = true;" ~/Web/rockmongo/config.php
    """
  start:
    """
    sudo service apache2 restart
    sudo apt-get clean all
    echo "*******************************************************"
    echo "*    Mongo DB is now installed on your VM, enjoy!     *"
    echo "*******************************************************"
    sleep 5
    exit
    """
    
mongoinstall  = FSHelper.createFileFromPath "~/Applications/MongoInstaller.kdapp/.mongoinstall.sh"
php           = FSHelper.createFileFromPath "~/Applications/MongoInstaller.kdapp/.php.sh"
rockmongo     = FSHelper.createFileFromPath "~/Applications/MongoInstaller.kdapp/.rockmongo.sh"
start         = FSHelper.createFileFromPath "~/Applications/MongoInstaller.kdapp/.start.sh"

mongoinstall.save files.mongoinstall
php.save files.php
rockmongo.save files.rockmongo
start.save files.start

class AppInstaller extends Recipe

  # Chose a name for your install recipe.
  name: "MongoDB Installer"
  icon: "http://#{USER}.kd.io/.applications/mongodb-installer/resources/icon.256.png" # Settings.defaultIcon
  desc: """
        Installs MongoDB Server, client and Rockmongo Manager.
        """
  path: "#{HOME}/Applications/MongoInstaller.kdapp"
  
  install: (terminal)->
    terminal.open()
    terminal.runCommand """
    sh #{@path}/.mongoinstall.sh; sh #{@path}/.php.sh; sh #{@path}/.rockmongo.sh; sh #{@path}/.start.sh
    """
  
  shell: (terminal)->
    terminal.open()
    terminal.runCommand "mongo"
    
  manage: ->
    modal = new KDModalView
      title: "Warning!"
      content: """
      <div class="modalformline">
      <p>This will open a public URL that everybody can access. Please manage your authentication settings on MongoDB.</p>
      </div>
      <pre>
      $ mongo
      > use admin
      > db.addUser("username", "password")
      </pre>
      """
      buttons:
        "Okay":
          cssClass: "modal-clean-red"
          callback: ->
            a = document.createElement "a"
            a.href = "http://#{USER}.kd.io/rockmongo"
            a.style.display = "none"
            a.target = "rockmongo"
            document.body.appendChild a
            a.click()
            document.body.removeChild a
            modal.destroy()
