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

    if editor[0]?
      text = editor[0].outerHTML
      type = 'text/html'
    else
      text = editor.getText?()
      type = 'text/plain'

    http = require 'http'
    server = http.createServer (req, res) =>
      res.writeHead 200, {'Content-Type': type}
      res.end text
    server.listen 8000, '127.0.0.1'

    server.addListener 'connection', (socket) =>
      sockets.push socket

    console.log('Broadcast started.')

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

    console.log('Broadcast stopped.')
