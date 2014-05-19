{View} = require 'atom'

module.exports =
class BroadcastView extends View
  @content: ->
    @div class: 'broadcast overlay from-top', =>
      @div "The Broadcast package is Alive! It's ALIVE!", class: "message"

  initialize: (serializeState) ->
    atom.workspaceView.command "broadcast:toggle", => @toggle()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  toggle: ->
    console.log "BroadcastView was toggled!"
    if @hasParent()
      @detach()
    else
      atom.workspaceView.append(this)
