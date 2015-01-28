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
    atom.commands.add 'atom-workspace',
      'broadcast:start': =>
        @start()
    atom.commands.add 'atom-workspace',
      'broadcast:stop': =>
        @stop()

  start: ->
    @server = new BroadcastServer() unless @server?
    @server.start()

  stop: ->
    @server?.stop()
