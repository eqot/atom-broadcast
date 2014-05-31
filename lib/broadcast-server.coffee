path = require 'path'
Shell = require 'shell'
http = require 'http'
socketIo = require 'socket.io'
nodeStatic = require 'node-static'

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

    hostname = atom.config.get('broadcast.hostname') or 'localhost'
    port = atom.config.get('broadcast.port') or 8000
    url = "http://#{hostname}:#{port}"

    @startServer hostname, port
    @startSocketIOServer()

    if !isRestart and atom.config.get 'broadcast.automaticallyOpenInBrowser'
      @openUrlInBrowser url + '/index.html'

    console.log "Broadcast started at #{url}"

  setupEditor: ->
    @editor = atom.workspace.activePaneItem

    @editor.on 'markdown-preview:markdown-changed', =>
      @updateContent()

  startServer: (hostname, port) ->
    filePath = path.join __dirname, '../public'
    fileServer = new nodeStatic.Server filePath

    @server = http.createServer (req, res) =>
      req.addListener 'end', =>
        req.url = decodeURIComponent(req.url)
        fileServer.serve req, res, (err) =>
          if err?
            console.log req.url
            console.log err
      .resume()
    .listen port, hostname

    @server.addListener 'connection', (socket) =>
      @sockets.push socket

  startSocketIOServer: ->
    return unless @server?

    io = socketIo @server

    io.on 'connection', (socket) =>
      @ioSocket = socket
      @updateContent()

  stop: ->
    if !@server?
      console.error 'Broadcast has not started'
      return

    if @sockets.length > 0
      for socket in @sockets
        socket.destroy()

    @server.close()
    @server = null

    console.log 'Broadcast stopped.'

  updateContent: ->
    return unless @ioSocket?

    content = @getContent()
    @ioSocket.emit 'update', content

  getContent: ->
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
