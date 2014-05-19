server = null

module.exports =
  activate: ->
    atom.workspaceView.command "broadcast:start", => @start()
    atom.workspaceView.command "broadcast:stop", => @stop()

  start: ->
    editor = atom.workspace.activePaneItem
    console.log(editor)
    text = editor.getText()

    http = require 'http'
    server = http.createServer (req, res) =>
      res.writeHead 200, {'Content-Type': 'text/plain'}
      res.end text
    server.listen 8000, '127.0.0.1'

    console.log('Broadcst started.')

  stop: ->
    if server isnt null
      server.close()
      server = null

    console.log('Broadcst stopped.')
