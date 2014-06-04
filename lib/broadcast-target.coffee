module.exports =
class BroadcastTarget
  editor: null
  listener: null
  isMarkdownPreview: false

  constructor: ->
    @editor = atom.workspace.activePaneItem

    @isMarkdownPreview = @editor[0]?

    if @isMarkdownPreview
      @editor.on 'markdown-preview:markdown-changed', =>
        @listener?()
    else
      @editor.getBuffer().on 'contents-modified', =>
        @listener?()

  setListener: (listener) ->
    @listener = listener

  getContent: ->
    return if @isMarkdownPreview then @getMarkdownPreviewContent() else @getOtherContent()

  getMarkdownPreviewContent: ->
    content = @editor[0].outerHTML
    if atom.config.get 'broadcast.getEmojisFromCheatSheetSite'
      content = content.replace /[\w-\.\/]+pngs/g, @urlToCheatSheetSite
    else
      content = content.replace /[\w-\.\/]+node_modules\/roaster\/node_modules/g, ''

  getOtherContent: ->
    content = @editor.getText?()
    .replace /</g, '&lt;'
    .replace />/g, '&gt;'

    return '<pre>' + content + '</pre>'
