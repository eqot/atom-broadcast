BroadcastServer = require './broadcast-server.coffee'

module.exports =
  configDefaults:
    hostname: 'localhost'
    port: 8000
    getEmojisFromCheatSheetSite: false

  activate: ->
    atom.workspaceView.command "broadcast:start", => BroadcastServer.start()
    atom.workspaceView.command "broadcast:stop", => BroadcastServer.stop()
