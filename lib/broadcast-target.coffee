module.exports =
class BroadcastTarget
  editor: null
  listener: null

  constructor: ->
    @editor = atom.workspace.activePaneItem

    @editor.on 'markdown-preview:markdown-changed', =>
      @listener?()

  setListener: (listener) ->
    @listener = listener

  getContent: ->
    if @editor[0]?
      content = @editor[0].outerHTML
      if atom.config.get 'broadcast.getEmojisFromCheatSheetSite'
        content = content.replace /[\w-\.\/]+pngs/g, @urlToCheatSheetSite
      else
        content = content.replace /[\w-\.\/]+node_modules\/roaster\/node_modules/g, ''
    else
      content = '<pre>' + @editor.getText?() + '</pre>'

    return content
