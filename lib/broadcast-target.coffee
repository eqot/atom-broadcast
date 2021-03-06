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
  disposable: null

  constructor: ->
    @editor = atom.workspace.getActivePaneItem()

    @contentType = @getContentType()

    switch @contentType
      when ContentType.MarkdownPreview
        @disposable = @editor.onDidChangeMarkdown? =>
          @listener?()

      when ContentType.HighlightedCode
        @disposable = @editor.getBuffer().onDidStopChanging? =>
          @listener?()

        Highlights = require 'highlights'
        @highlighter = new Highlights()

  destroy: ->
    @removeListener()

    @disposable?.dispose()

  getContentType: ->
    if @editor.element.classList.contains('markdown-preview')
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
    content = @editor.element.outerHTML
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
