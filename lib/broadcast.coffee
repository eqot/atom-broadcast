BroadcastServer = require './broadcast-server.coffee'

module.exports =
  config:
    hostname:
      type: 'string'
      default: 'localhost'
    port:
      type: 'integer'
      default: 8000
    getEmojisFromCheatSheetSite:
      type: 'boolean'
      default: false
    automaticallyOpenInBrowser:
      type: 'boolean'
      default: true
    broadcastToOthers:
      type: 'boolean'
      default: false
    codeHighlight:
      type: 'boolean'
      default: true

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
