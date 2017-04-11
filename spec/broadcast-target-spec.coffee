BroadcastTarget = require('../lib/broadcast-target.coffee')

describe "BroadcastTarget", ->
  target = null

  describe "when broadcast highlighted code", ->
    beforeEach ->
      atom.config.set('broadcast.codeHighlight', true)

      waitsForPromise -> atom.workspace.open('sample.md')
      runs -> target = new BroadcastTarget()

    it "has the right content type", ->
      expect(target.getContentType()).toBe(1)

    it "has the right title", ->
      expect(target.getTitle()).toBe('sample.md')

    it "has the right content", ->
      expect(target.getContent()).toBe('<pre class="editor editor-colors"><div class="line"><span class="source gfm"><span class="markup heading heading-2 gfm"><span>##&nbsp;</span><span>Sample&nbsp;</span><span class="string emoji gfm"><span class="string emoji start gfm"><span>:</span></span><span class="string emoji word gfm"><span>+1</span></span><span class="string emoji end gfm"><span>:</span></span></span></span></span></div></pre>')

  describe "when broadcast non-highlight code", ->
    beforeEach ->
      atom.config.set('broadcast.codeHighlight', false)

      waitsForPromise -> atom.workspace.open('sample.md')
      runs -> target = new BroadcastTarget()

    it "has the right content type", ->
      expect(target.getContentType()).toBe(-1)

    it "has the right content", ->
      expect(target.getContent()).toBe('<pre>## Sample :+1:\n</pre>')

  describe "when broadcast markdown preview", ->
    beforeEach ->
      atom.config.set('broadcast.getEmojisFromCheatSheetSite', false)

      waitsForPromise -> atom.workspace.open('sample.html')

      # Fake this content is markdown preview
      spyOn(BroadcastTarget.prototype, 'getContentType').andReturn(0)

      runs ->
        target = new BroadcastTarget()
        target.editor = { element: { outerHTML: target.editor.getText() } }

    it "has the right content type", ->
      expect(target.getContentType()).toBe(0)

    it "has the right content", ->
      expect(target.getContent()).toBe('<div class="markdown-preview native-key-bindings" tabindex="-1" callattachhooks="true"><h2 id="sample-1-">Sample <img class="emoji" title=":+1:" alt="+1" src="/emoji-images/pngs/%2B1.png" height="20"></h2></div>\n')

    it "has the right content with the right emoji from Emoji Cheat Sheet", ->
      atom.config.set('broadcast.getEmojisFromCheatSheetSite', true)
      expect(target.getContent()).toBe('<div class="markdown-preview native-key-bindings" tabindex="-1" callattachhooks="true"><h2 id="sample-1-">Sample <img class="emoji" title=":+1:" alt="+1" src="https://raw.githubusercontent.com/arvida/emoji-cheat-sheet.com/master/public/graphics/emojis/%2B1.png" height="20"></h2></div>\n')
