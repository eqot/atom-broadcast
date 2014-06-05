BroadcastServer = require './broadcast-server.coffee'

module.exports =
  configDefaults:
    hostname: 'localhost'
    port: 8000
    getEmojisFromCheatSheetSite: false
    automaticallyOpenInBrowser: true
    broadcastToOthers: false
    codeHighlight: true

  server: null

  activate: ->
    atom.workspaceView.command 'broadcast:start', => @start()
    atom.workspaceView.command 'broadcast:stop', => @stop()

  start: ->
    @server = new BroadcastServer() unless @server?
    @server.start()

  stop: ->
    @server?.stop()
