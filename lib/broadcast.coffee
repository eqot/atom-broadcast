path = require 'path'
fs = require 'fs'
nodeStatic = require 'node-static'

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
    if editor[0]?
      text = editor[0].outerHTML
      type = 'text/html'
    else
      text = editor.getText?()
      type = 'text/plain'

    filePath = path.join __dirname, '..', './public'
    fileServer = new nodeStatic.Server filePath

    template = fs.readFileSync path.join(filePath, 'template.html'), {encoding: 'utf8'}
    text = template.replace '{CONTENT}', text

    type = 'text/html'

    http = require 'http'
    server = http.createServer (req, res) =>
      req.addListener 'end', =>
        fileServer.serve req, res, (err) =>
          if err?
            res.writeHead 200, {'Content-Type': type}
            res.end text
      .resume()
    .listen 8000, '127.0.0.1'

    server.addListener 'connection', (socket) =>
      sockets.push socket

    console.log 'Broadcast started.'

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

    console.log 'Broadcast stopped.'
