BroadcastView = require './broadcast-view'

module.exports =
  broadcastView: null

  activate: (state) ->
    @broadcastView = new BroadcastView(state.broadcastViewState)

  deactivate: ->
    @broadcastView.destroy()

  serialize: ->
    broadcastViewState: @broadcastView.serialize()
