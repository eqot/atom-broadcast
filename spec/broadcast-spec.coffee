http = require('http')
Shell = require('shell')

describe "Broadcast", ->
  beforeEach ->
    atom.config.set('broadcast.automaticallyOpenInBrowser', false)

    waitsForPromise -> atom.packages.activatePackage('broadcast')
    waitsForPromise -> atom.workspace.open('sample.md')
    runs -> editor = atom.workspace.getActiveTextEditor()

  describe "when the broadcast:start event is triggered", ->
    it "start a built-in server at right hostname and port", ->
      atom.config.set('broadcast.automaticallyOpenInBrowser', true)
      atom.config.set('broadcast.hostname', 'dummy')
      atom.config.set('broadcast.port', '1234')

      server = new http.Server()
      spyOn(http, 'createServer').andReturn(server)
      spyOn(server, 'close')
      spyOn(Shell, 'openExternal')

      workspaceElement = atom.views.getView(atom.workspace)
      atom.commands.dispatch(workspaceElement, 'broadcast:start')

      runs ->
        expect(http.createServer).toHaveBeenCalled()
        expect(Shell.openExternal).toHaveBeenCalledWith('http://dummy:1234')

        atom.commands.dispatch(workspaceElement, 'broadcast:stop')

        expect(server.close).toHaveBeenCalled()
