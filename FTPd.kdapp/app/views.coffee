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
    
  pistachio: ->
    """
    <header>
      <img src="#{@recipe.icon}" onerror="this.src='#{Installer.Settings.defaultIcon}'">
      <div>
        <h1>#{@recipe.name}</h1>
        <p>
          #{@recipe.desc}
        </p>
      </div>
      {{> @buttonsView}}
    </header>
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