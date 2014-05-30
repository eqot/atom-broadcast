path = require 'path'
fs = require 'fs'
nodeStatic = require 'node-static'
Shell = require 'shell'

server = null
sockets = []

module.exports =
class BroadcastServer
  urlToCheatSheetSite: 'https://raw.githubusercontent.com/arvida/emoji-cheat-sheet.com/master/public/graphics/emojis'

  @start: ->
    # If server has already started, then it should stop first
    isRestart = server?
    if isRestart
      @stop()

    filePath = path.join __dirname, '..'
    template = fs.readFileSync path.join(filePath, 'template.html'), {encoding: 'utf8'}

    editor = atom.workspace.activePaneItem
    if editor[0]?
      content = editor[0].outerHTML
      if atom.config.get 'broadcast.getEmojisFromCheatSheetSite'
        content = content.replace /[\w-\.\/]+pngs/g, @urlToCheatSheetSite
      else
        content = content.replace /[\w-\.\/]+node_modules\/roaster/g, ''
    else
      content = '<pre>' + editor.getText?() + '</pre>'
    template = template.replace '{CONTENT}', content

    fileServer = new nodeStatic.Server filePath

    hostname = atom.config.get('broadcast.hostname') or 'localhost'
    port = atom.config.get('broadcast.port') or 8000

    http = require 'http'
    server = http.createServer (req, res) =>
      req.addListener 'end', =>
        req.url = decodeURIComponent(req.url)
        fileServer.serve req, res, (err) =>
          if err?
            res.writeHead 200, {'Content-Type': 'text/html'}
            res.end template
      .resume()
    .listen port, hostname

    server.addListener 'connection', (socket) =>
      sockets.push socket

    url = "http://#{hostname}:#{port}"
    if !isRestart and atom.config.get 'broadcast.automaticallyOpenInBrowser'
      @openUrlInBrowser url

    console.log "Broadcast started at #{url}"

  @stop: ->
    if server is null
      console.error 'Broadcast has not started'
      return

    if sockets.length > 0
      for socket in sockets
        socket.destroy()

    server?.close()
    server = null

    console.log 'Broadcast stopped.'

  @openUrlInBrowser: (url) ->
    Shell.openExternal url
