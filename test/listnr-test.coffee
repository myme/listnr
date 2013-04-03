Listnr = @Listnr
buster = @buster

assert = buster.assert
refute = buster.refute

createEl = (tag) ->
  document.createElement(tag)

triggerCombo = (el, combo) ->
  keyCode = combo.charCodeAt(0)
  event = document.createEvent('KeyboardEvent')
  event.initKeyboardEvent(
    'keypress',  #  event type
     true,       #  can bubble
     true,       #  cancelable
     null,       #  UIEvent.view
     false,      #  ctrl key
     false,      #  alt key
     false,      #  shift key
     false,      #  meta key
     keyCode,    #  key code
     0)          #  char code
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

      assert.calledOnceWith(spy, combo)
      assert.calledOn(spy, @listnr)

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
