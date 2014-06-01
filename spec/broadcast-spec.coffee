{WorkspaceView} = require 'atom'

http = require 'http'
Shell = require 'shell'

describe "Broadcast", ->
  activationPromise = null

  beforeEach ->
    atom.config.set 'broadcast.automaticallyOpenInBrowser', false

    atom.workspaceView = new WorkspaceView()
    atom.workspaceView.openSync 'sample.md'
    atom.workspaceView.simulateDomAttachment()

    activationPromise = atom.packages.activatePackage('broadcast')

  describe "when the broadcast:start event is triggered", ->
    it "start a built-in server at right hostname and port", ->
      atom.config.set 'broadcast.automaticallyOpenInBrowser', true
      atom.config.set 'broadcast.hostname', 'dummy'
      atom.config.set 'broadcast.port', '1234'

      server = new http.Server()
      spyOn(http, 'createServer').andReturn server
      spyOn server, 'close'
      spyOn Shell, 'openExternal'

      atom.workspaceView.trigger 'broadcast:start'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(http.createServer).toHaveBeenCalled()
        expect(Shell.openExternal).toHaveBeenCalledWith 'http://dummy:1234'

        atom.workspaceView.trigger 'broadcast:stop'

        expect(server.close).toHaveBeenCalled()
