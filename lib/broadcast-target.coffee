module.exports =
class BroadcastTarget
  ContentType =
    Unknown: -1
    MarkdownPreview: 0
    HighlightedCode: 1

  urlToCheatSheetSite: 'https://raw.githubusercontent.com/arvida/emoji-cheat-sheet.com/master/public/graphics/emojis'

  editor: null
  listener: null
  contentType: null
  highlighter: null

  constructor: ->
    @editor = atom.workspace.activePaneItem

    @contentType = @getContentType()

    switch @contentType
      when ContentType.MarkdownPreview
        @editor.on 'markdown-preview:markdown-changed', =>
          @listener?()

      when ContentType.HighlightedCode
        @editor.getBuffer().on 'contents-modified', =>
          @listener?()

        Highlights = require 'highlights'
        @highlighter = new Highlights()

  getContentType: ->
    if @editor[0]?
      return ContentType.MarkdownPreview
    else if atom.config.get('broadcast.codeHighlight')
      return ContentType.HighlightedCode

    return ContentType.Unknown

  setListener: (listener) ->
    @listener = listener

  removeListener: ->
    @listener = null

  getTitle: ->
    @editor.getTitle()

  getContent: ->
    switch @contentType
      when ContentType.MarkdownPreview
        @getMarkdownPreviewContent()

      when ContentType.HighlightedCode
        @getHighlightedCodeContent()

      else
        @getPlainTextContent()

  getMarkdownPreviewContent: ->
    content = @editor[0].outerHTML
    if atom.config.get 'broadcast.getEmojisFromCheatSheetSite'
      content = content.replace /[\w-\.\/]+pngs/g, @urlToCheatSheetSite
    else
      content = content.replace /[\w-\.\/]+node_modules\/roaster\/node_modules/g, ''

  getHighlightedCodeContent: ->
    if @editor.getPath()?
      @highlighter.highlightSync
        filePath: @editor.getPath()
    else
      @getPlainTextContent()

  getPlainTextContent: ->
    content = @editor.getText?()
    .replace /</g, '&lt;'
    .replace />/g, '&gt;'

    return '<pre>' + content + '</pre>'
