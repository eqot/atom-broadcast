path = require 'path'
fs = require 'fs'
nodeStatic = require 'node-static'
Shell = require 'shell'

module.exports =
class BroadcastServer
  urlToCheatSheetSite: 'https://raw.githubusercontent.com/arvida/emoji-cheat-sheet.com/master/public/graphics/emojis'

  editor: null
  server: null
  sockets: []
  ioSocket: null

  start: ->
    isRestart = @server?
    if isRestart
      @stop()

    @setupEditor()

    content = @getEditorContent()
    url = @startServer()
    @startSocketIOServer()

    if !isRestart and atom.config.get 'broadcast.automaticallyOpenInBrowser'
      @openUrlInBrowser url

    console.log "Broadcast started at #{url}"

  setupEditor: ->
    @editor = atom.workspace.activePaneItem

    @editor.on 'markdown-preview:markdown-changed', =>
      # console.log 'Updated!'
      @updateContent()

  startServer: ->
    hostname = atom.config.get('broadcast.hostname') or 'localhost'
    port = atom.config.get('broadcast.port') or 8000
    url = "http://#{hostname}:#{port}"

    filePath = path.join __dirname, '..'
    template = fs.readFileSync path.join(filePath, 'template.html'), {encoding: 'utf8'}

    fileServer = new nodeStatic.Server filePath

    http = require 'http'
    @server = http.createServer (req, res) =>
      req.addListener 'end', =>
        req.url = decodeURIComponent(req.url)
        fileServer.serve req, res, (err) =>
          if err?
            res.writeHead 200, {'Content-Type': 'text/html'}
            res.end template
      .resume()
    .listen port, hostname

    @server.addListener 'connection', (socket) =>
      @sockets.push socket

    return url

  startSocketIOServer: ->
    if !@server?
      return

    io = require('socket.io') @server

    io.on 'connection', (socket) =>
      @ioSocket = socket
      @updateContent()

  stop: ->
    if @server is null
      console.error 'Broadcast has not started'
      return

    if @sockets.length > 0
      for socket in @sockets
        socket.destroy()

    @server?.close()
    @server = null

    console.log 'Broadcast stopped.'

  updateContent: ->
    return unless @ioSocket?

    content = @getEditorContent()
    @ioSocket.emit 'update', content

  getEditorContent: ->
    if @editor[0]?
      content = @editor[0].outerHTML
      if atom.config.get 'broadcast.getEmojisFromCheatSheetSite'
        content = content.replace /[\w-\.\/]+pngs/g, @urlToCheatSheetSite
      else
        content = content.replace /[\w-\.\/]+node_modules\/roaster/g, ''
    else
      content = '<pre>' + @editor.getText?() + '</pre>'

    return content

  openUrlInBrowser: (url) ->
    Shell.openExternal url
