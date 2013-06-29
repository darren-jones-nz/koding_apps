{Settings}  = Installer
{Recipe}    = Installer.Core
{nickname}  = KD.whoami().profile

files =
  ftpinstall:
    """
    export DEBIAN_FRONTEND=noninteractive
    sudo apt-get -y -q install pure-ftpd
    """
    
ftpinstall  = FSHelper.createFileFromPath "~/Applications/FTPd.kdapp/.ftpinstall.sh"

ftpinstall.save files.ftpinstall

class AppInstaller extends Recipe

  # Chose a name for your install recipe.
  name: "FTP Installer"
  icon: "http://#{USER}.kd.io/.applications/ftpd-installer/resources/icon.256.png" # Settings.defaultIcon
  desc: """
        Installs FTP so you can connect to your VM with FTP.<br/><br/>
        Once installed you connect to your VM by FTPing to the domain associated with your vm, for example vm-3.#{nickname}.koding.kd.io<br/>
        Your username should be #{nickname}@vm-3.#{nickname}.koding.kd.io<br/>
        Your password is your koding password
        """
  path: "#{HOME}/Applications/FTPd.kdapp"
  
  install: (terminal)->
    terminal.open()
    terminal.runCommand """
    sh #{@path}/.ftpinstall.sh
    """