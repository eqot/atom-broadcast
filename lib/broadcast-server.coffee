path = require 'path'
Shell = require 'shell'
http = require 'http'
socketIo = require 'socket.io'
nodeStatic = require 'node-static'

BroadcastTarget = require './broadcast-target.coffee'

module.exports =
class BroadcastServer
  urlToCheatSheetSite: 'https://raw.githubusercontent.com/arvida/emoji-cheat-sheet.com/master/public/graphics/emojis'

  target: null
  server: null
  sockets: []
  io: null

  start: ->
    isRestart = @server?
    if isRestart
      @stop()

    @target = new BroadcastTarget()
    @target.setListener @onUpdateTarget

    hostname = atom.config.get('broadcast.hostname') or 'localhost'
    port = atom.config.get('broadcast.port') or 8000
    url = "http://#{hostname}:#{port}"

    @startServer hostname, port
    @startSocketIOServer()

    if !isRestart and atom.config.get 'broadcast.automaticallyOpenInBrowser'
      @openUrlInBrowser url

    console.log "Broadcast started at #{url}"

  startServer: (hostname, port) ->
    filePath = path.join __dirname, '../public'
    fileServer = new nodeStatic.Server filePath

    modulePath = path.join __dirname, '../node_modules/'
    moduleServer = new nodeStatic.Server modulePath

    ip = if atom.config.get 'broadcast.broadcastToOthers' then '0.0.0.0' else '127.0.0.1'

    @server = http.createServer (req, res) =>
      req.addListener 'end', =>
        req.url = decodeURIComponent(req.url)
        fileServer.serve req, res, (err) =>
          if err?
            moduleServer.serve req, res, (err2) =>
              if err2?
                console.log req.url
                console.log err2
      .resume()
    .listen port, ip

    @server.addListener 'connection', (socket) =>
      @sockets.push socket

  startSocketIOServer: ->
    return unless @server?

    @io = socketIo @server

    @io.on 'connection', (socket) =>
      @onUpdateTarget socket

  stop: ->
    if !@server?
      console.log 'Broadcast has not started'
      return

    @stopSocketIOServer()
    @stopServer()

    @target.destroy()

    console.log 'Broadcast stopped.'

  stopServer: ->
    if @sockets.length > 0
      for socket in @sockets
        socket.destroy()

    @server.close()
    @server = null

  stopSocketIOServer: ->
    return unless @io?
    @io = null

  onUpdateTarget: (socket) =>
    targetData =
      title: @target.getTitle()
      content: @target.getContent()

    if socket?
      socket.emit 'update', targetData
    else
      @io.emit 'update', targetData

  openUrlInBrowser: (url) ->
    Shell.openExternal url
