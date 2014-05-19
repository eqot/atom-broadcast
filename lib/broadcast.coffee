server = null
sockets = []

module.exports =
  activate: ->
    atom.workspaceView.command "broadcast:start", => @start()
    atom.workspaceView.command "broadcast:stop", => @stop()

  start: ->
    if server isnt null
      console.error 'Broadcast has already started'
      return

    editor = atom.workspace.activePaneItem
    console.log(editor)
    text = editor.getText()

    http = require 'http'
    server = http.createServer (req, res) =>
      res.writeHead 200, {'Content-Type': 'text/plain'}
      res.end text
    server.listen 8000, '127.0.0.1'

    server.addListener 'connection', (socket) =>
      sockets.push socket

    console.log('Broadcst started.')

  stop: ->
    if server is null
      console.error 'Broadcast has not started'
      return

    if sockets.length > 0
      for socket in sockets
        socket.destroy()

    if server isnt null
      server.close()
      server = null

    console.log('Broadcst stopped.')
