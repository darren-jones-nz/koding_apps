{BaseView}  = Installer.Views
{notify}    = Installer.Utilities

class Installer.Views.Dashboard extends BaseView
  
  constructor: (options={}, data)->

    options.cssClass = "installer-dashboard"
    super options, data
    
    {@terminal} = @options
    @recipe = new AppInstaller
    
  runRecipe: (cmd)->
    if typeof cmd is "string"
      @terminal.runCommand cmd
    else if typeof recipe is "function"
      cmd @options.terminal
    
  delegateElements: ->
    
    run = (method)=> @runRecipe @recipe[method] @terminal

    @buttonsView = new KDView
      cssClass: "buttons"
    
    @buttonsView.addSubView @installButton = new KDButtonView
      title     : "Install"
      callback  : =>
        unless @recipe.install then return notify "Installation recipe not found."
        run "install"

    if @recipe.shell
      @buttonsView.addSubView @shellButton = new KDButtonView
        title     : "Shell"
        callback  : => run "shell"

    if @recipe.manage
      @buttonsView.addSubView @manageButton = new KDButtonView
        title     : "Manage"
        callback  : => run "manage"
          
    if @recipe.uninstall
      @buttonsView.addSubView @manageButton = new KDButtonView
        title     : "Uninstall"
        callback  : => run "uninstall"
          
    @buttonsView.addSubView @toggleTerminaButton = new KDButtonView
      title     : "Terminal"
      callback  : => @terminal.toggle()
      
    @vmListViewController = new VMListViewController
      itemClass : VMListViewItem
      
    @vmListView = @vmListViewController.getView() 
    
  pistachio: ->
    """
    <header>
      <img src="#{@recipe.icon}" onerror="this.src='#{Installer.Settings.defaultIcon}'">
      <div class="desc">
        <h1>#{@recipe.name}</h1>
        <p>
          #{@recipe.desc}
        </p>
        <br><br>
        <h2>Your VM(s)</h2>
        {{> @vmListView}}
      </div>
      {{> @buttonsView}}
    </header>
    """

class VMListViewController extends KDListViewController
  loadView:->
    super
    @loadItems()

  loadItems:(callback)->
    @removeAllItems()
    @customItem?.destroy()
    @showLazyLoader no

    KD.remote.api.JVM.fetchVms (err, vms)=>
      items = []
      vms.forEach (vmHost)->
        items.push
          hostname: vmHost
          
      @hideLazyLoader()
      if items.length is 0
        @addCustomItem "You don't have any VMs yet."
      else
        @instantiateListItems items

  addCustomItem:(message)->
    @removeAllItems()
    @customItem?.destroy()
    @scrollView.addSubView @customItem = new KDCustomHTMLView
      cssClass : "no-item-found"
      partial  : message

class VMListViewItem extends KDListItemView
  partial:(data)->
    """
      <strong>FTP address:</strong> #{data.hostname}
      <br>
      <strong>Username:</strong> #{USER}@#{data.hostname}
      <br>
      <br>
    """
    
class Installer.Views.TerminalView extends BaseView

  remote: {}
  
  exec: (command)->
    @remote.input command + "\n"
  
  runCommand: (command=no)->
    @open()
    @remote.input command + "\n" if command
   
  open: ->
    @$().addClass("shown")
    @webterm.click()
  
  close: -> @$().removeClass("shown")
  
  toggle: ->
    @$().toggleClass("shown")
    if @$().is ".shown" then @webterm.click()

  constructor: (options={}, data)->
    
    options.cssClass = "installer-terminal"
    super options, data
    
  delegateElements: ->
    @webterm = new WebTermView
      delegate : @
      cssClass : "webterm"
    @webterm.on "WebTermConnected", (@remote)=>
      $(window).resize()
    @webterm.on "WebTerm.terminated", =>
      @emit "terminate"
    
  pistachio: ->
    """
    {{> @webterm}}
    """


class Installer.Views.MainView extends BaseView
  
  {Dashboard, TerminalView} = Installer.Views
  
  constructor: (options={}, data)->
    options.cssClass = "installer-container"
    super options, data

  # Element Delegation
  delegateElements: ->
    
    @terminal  = new TerminalView
    @terminal.on "terminate", =>
      @terminal.close()
      KD.utils.wait 700, =>
        @removeSubView @terminal
        @removeSubView @dashboard
        @viewAppended()
        
    @dashboard = new Dashboard
      terminal: @terminal

  pistachio:->
    """
    {{> @dashboard}}
    {{> @terminal}}
    """
