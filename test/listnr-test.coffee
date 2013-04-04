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
  for key in combo.split(' ')
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
        .map('a b', comboSpy)
        .map('b', singleSpy)
      triggerCombo(@el, 'a b')

      assert.calledOnce(comboSpy)
      refute.called(singleSpy)

    'can register multiple mappings for the same handler': ->
      spy = @spy()

      @listnr.map('a|b', spy)
      triggerCombo(@el, 'a')
      triggerCombo(@el, 'b')

      assert.calledTwice(spy)
      assert.calledWith(spy, 'a')
      assert.calledWith(spy, 'b')

  '.unmap':

    setUp: ->
      @el = createEl('div')
      @combo = 'a'
      @keySpy = @spy()
      @listnr = new Listnr(el: @el)
        .map(@combo, @keySpy)

    'returns self': ->
      assert.same(@listnr.unmap(@combo), @listnr)

    'removes listener': ->
      @listnr.unmap(@combo)

      triggerCombo(@el, @combo)

      refute.called(@keySpy)

    'can remove single mapping of aliased listeners': ->
      spy = @spy()

      @listnr
        .map('b|c', spy)
        .unmap('b')

      triggerCombo(@el, 'b')
      triggerCombo(@el, 'c')

      assert.calledOnceWith(spy, 'c')

    'can remove multiple listeners': ->
      spy = @spy()

      @listnr
        .map('b|c', spy)
        .unmap('b|c')

      triggerCombo(@el, 'b')
      triggerCombo(@el, 'c')

      refute.called(spy)

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

  '.always':

    setUp: ->
      @el = createEl('div')
      @listnr = new Listnr(el: @el)

    'returns self': ->
      assert.same(@listnr.always(), @listnr)

    'adds a handler executed for all combinations': ->
      always = @spy()
      spy = @spy()

      @listnr
        .always(always)
        .map('a', spy)
      triggerCombo(@el, 'a')

      assert.calledOnceWith(spy, 'a')
      assert.calledOnceWith(always, 'a')

    'triggers even with no handlers': ->
      spy = @spy()

      @listnr.always(spy)
      triggerCombo(@el, 'a')

      assert.calledOnceWith(spy, 'a')

    'triggers individually when no combo': ->
      spy = @spy()

      @listnr.always(spy)
      triggerCombo(@el, 'a b')

      assert.calledTwice(spy)
      assert.calledWith(spy, 'a')
      assert.calledWith(spy, 'b')

    'triggers once for each key in a combo': ->
      spy = @spy()

      @listnr
        .map('a b', ->)
        .always(spy)
      triggerCombo(@el, 'a b')

      assert.calledTwice(spy)
      assert.calledWith(spy, 'a')
      assert.calledWith(spy, 'a b')

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

    'clears combo for default handler': ->
      spy = @spy()

      @listnr.default(spy)
      triggerCombo(@el, 'a b')

      assert.calledTwice(spy)
      assert.calledWith(spy, 'a')
      assert.calledWith(spy, 'b')

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
        .map('a b', 'Mapping for "a b"', ->)
        .map('c d e', 'Mapping for "c d e"', ->)
        .help()

      assert.equals help,
        'a b': 'Mapping for "a b"'
        'c d e': 'Mapping for "c d e"'

    'handles aliases nicely': ->
      help = new Listnr()
        .map('a|b', 'Mapping for foo', ->)
        .help()

      assert.equals help,
        'a': 'Mapping for foo'
        'b': 'Mapping for foo'

    'with combo argument returns help for mapping': ->
      help = new Listnr()
        .map('a b', 'Mapping for "a b"', ->)
        .map('b', 'Mapping for "b"', ->)
        .help('a b')

      assert.equals(help, 'Mapping for "a b"')

    'with combo argument returns undefined for missing mapping': ->
      help = new Listnr()
        .map('a b', 'Mapping for "a b"', ->)
        .map('b', 'Mapping for b', ->)
        .help('c d')

      assert.equals(help, undefined)
