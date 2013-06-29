# Globals
USER      = KD.nick()
HOME      = "/home/#{USER}"

# Core Structure
Installer =
  Core      : {}
  Utilities : {}
  Models    : {}
  Views     : {}
  Settings  :
    defaultIcon: "https://koding.com/images/default.app.thumb.png"

# Core Helper Views
class Installer.Views.BaseView extends JView
  constructor: (options={}, data) ->
    super options, data
  
  viewAppended: ->
    @delegateElements()
    @setTemplate do @pistachio
    
class Installer.Core.Recipe
  name        : "An Installer"
  description : "An installer recipe"
  depends     : []
  install     : no
  terminal    : no
  uninstall   : no
  manage      : no