###
Installer App for Koding Apps
###
{Recipe}    = Installer.Core
{notify}    = Installer.Utilities
{MainView}  = Installer.Views

do ->
  try
    appView.addSubView new MainView
  catch error
    console.log error
    notify error