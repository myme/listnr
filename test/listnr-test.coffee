Listnr = @Listnr
buster = @buster

assert = buster.assert
refute = buster.refute

createEl = (tag) ->
  document.createElement(tag)

triggerKeypress = (el, keyCode) ->
  event = document.createEvent('Event')
  event.initEvent('keypress', true, true)
  event.keyCode = keyCode
  el.dispatchEvent(event)

triggerCombo = (el, combo) ->
  for key in combo.split('+')
    triggerKeypress(el, key.charCodeAt(0))

buster.testCase 'Listnr',

  'can instantiate': ->
    listnr = new Listnr()
    assert(listnr instanceof Listnr)

  '.map':

    setUp: ->
      @el = createEl('div')
      @listnr = new Listnr(el: @el)

    'returns self': ->
      assert.same(@listnr.map('a', ->), @listnr)

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

      assert.calledOnceWith(spy, combo)
      assert.calledOn(spy, @listnr)

    'only triggers on match': ->
      spy = @spy()

      @listnr.map('a', spy)
      triggerCombo(@el, 'b')

      refute.called(spy)

    'can add help text': ->
      spy = @spy()

      @listnr.map('a', 'Mapping description', spy)
      triggerCombo(@el, 'a')

      assert.calledOnceWith(spy, 'a')

    '"enter" maps to 13': ->
      spy = @spy()

      @listnr.map('enter', spy)
      triggerKeypress(@el, 13)

      assert.calledOnceWith(spy, 'enter')

    'can register combos': ->
      comboSpy = @spy()
      singleSpy = @spy()

      @listnr
        .map('a+b', comboSpy)
        .map('b', singleSpy)
      triggerCombo(@el, 'a+b')

      assert.calledOnce(comboSpy)
      refute.called(singleSpy)

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

      @listnr
        .map('a', defaultHandler)
        .addContext('menu')
        .map('a', ctxHandler)
        .activate()

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

    '// allow activating multiple contexts': ->
      defSpy = @spy()
      ctxSpy = @spy()

      @listnr
        .map('a', defSpy)
        .addContext('context')
        .map('b', ctxSpy)
        .activate('default', 'context')

      triggerCombo(@el, 'a')
      triggerCombo(@el, 'b')

      assert.calledOnce(defSpy)
      assert.calledOnce(ctxSpy)

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

  '.default':

    setUp: ->
      @el = createEl('div')
      @listnr = new Listnr(el: @el)

    'returns self': ->
      assert.same(@listnr.default(), @listnr)

    'adds a default handler for all non-matching combos': ->
      spy = @spy()

      @listnr.default(spy)
      triggerCombo(@el, 'a')

      assert.calledOnceWith(spy, 'a')

  '.help':

    'returns help text': ->
      help = new Listnr()
        .map('a', 'Mapping for a', ->)
        .map('b', ->)
        .map('c', 'Mapping for c', ->)
        .help()

      assert.equals help,
        'a': 'Mapping for a'
        'b': null
        'c': 'Mapping for c'

    'returns help for the active context': ->
      help = new Listnr()
        .map('a', 'Mapping for a', ->)
        .addContext('context')
        .map('b', ->)
        .map('c', 'Mapping for c', ->)
        .help()

      assert.equals help,
        'b': null
        'c': 'Mapping for c'

    'handles combos nicely': ->
      help = new Listnr()
        .map('a+b', 'Mapping for a+b', ->)
        .map('c+d+e', 'Mapping for c+d+e', ->)
        .help()

      assert.equals help,
        'a+b': 'Mapping for a+b'
        'c+d+e': 'Mapping for c+d+e'
