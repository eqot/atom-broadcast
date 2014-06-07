BroadcastTarget = require '../lib/broadcast-target.coffee'

describe "BroadcastTarget", ->
  target = null
  activationPromise = null

  describe "when code highlight is enabled", ->
    beforeEach ->
      atom.config.set 'broadcast.codeHighlight', true

      atom.workspace.openSync 'sample.md'

      target = new BroadcastTarget()

    it "has the right content type", ->
      expect(target.getContentType()).toBe 1

    it "has the right title", ->
      expect(target.getTitle()).toBe 'sample.md'

    it "has the right content", ->
      expect(target.getContent()).toBe '<pre class="editor editor-colors"><div class="line"><span class="source gfm"><span class="markup heading heading-2 gfm"><span>##&nbsp;</span><span>Sample</span></span></span></div></pre>'

  describe "when code highlight is disabled", ->
    beforeEach ->
      atom.config.set 'broadcast.codeHighlight', false

      atom.workspace.openSync 'sample.md'

      target = new BroadcastTarget()

    it "has the right content type", ->
      expect(target.getContentType()).toBe -1

    it "has the right content", ->
      expect(target.getContent()).toBe '<pre>## Sample\n</pre>'
