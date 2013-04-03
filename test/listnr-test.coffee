Listnr = @Listnr
buster = @buster

assert = buster.assert
refute = buster.refute

createEl = (tag) ->
  document.createElement(tag)

triggerCombo = (el, combo) ->
  event = document.createEvent('Event')
  event.initEvent('keypress', true, true)
  event.keyCode = combo.charCodeAt(0)
  el.dispatchEvent(event)

buster.testCase 'Listnr',

  'can instantiate': ->
    listnr = new Listnr()
    assert(listnr instanceof Listnr)

  '.map':

    setUp: ->
      @el = createEl('div')
      @listnr = new Listnr(el: @el)

    'returns self': ->
      assert.same(@listnr.map(), @listnr)

    'does not call the handler': ->
      combo = 'a'
      spy = @spy()

      @listnr.map(combo, spy)

      refute.called(spy)

    'creates a new listener which is triggered on keyboard events': ->
      combo = 'a'
      spy = @spy()

      @listnr.map(combo, spy)
      triggerCombo(@el, combo)

      assert.calledOnce(spy)
      assert.calledOn(spy, @listnr)

    'only triggers on match': ->
      spy = @spy()

      @listnr.map('a', spy)
      triggerCombo(@el, 'b')

      refute.called(spy)

  '.unmap':

    setUp: ->
      @el = createEl('div')
      @combo = 'a'
      @keySpy = @spy()
      @listnr = new Listnr(el: @el)
        .map(@combo, @keySpy)

    'returns self': ->
      assert.same(@listnr.unmap(), @listnr)

    'removes listener': ->
      @listnr.unmap(@combo)

      triggerCombo(@el, @combo)

      refute.called(@keySpy)

  '.addContext':

    setUp: ->
      @el = createEl('div')
      @listnr = new Listnr(el: @el)

    'adds a new context of mappings': ->
      ctxHandler = @spy()
      defaultHandler = @spy()

      @listnr.map('a', defaultHandler)
      ctx = @listnr.addContext('menu')
      ctx.map('a', ctxHandler)
      ctx.activate()

      triggerCombo(@el, 'a')

      assert.calledOnce(ctxHandler)
      refute.called(defaultHandler)

  '.activate':

    setUp: ->
      @el = createEl('div')
      @listnr = new Listnr(el: @el)

    'returns self': ->
      assert.same(@listnr.activate(), @listnr)

    'can activate context by name': ->
      spy = @spy()
      @listnr
        .addContext('context')
        .map('a', spy)

      @listnr.activate('context')
      triggerCombo(@el, 'a')

      assert.calledOnce(spy)

  '.reset':

    setUp: ->
      @el = createEl('div')
      @listnr = new Listnr(el: @el)

    'returns self': ->
      assert.same(@listnr.reset(), @listnr)

    'returns to the default context': ->
      ctxSpy = @spy()
      defSpy = @spy()

      @listnr
        .map('a', defSpy)
        .addContext('context')
        .map('a', ctxSpy)
        .activate()

      @listnr.reset()
      triggerCombo(@el, 'a')

      assert.calledOnce(defSpy)
      refute.called(ctxSpy)
