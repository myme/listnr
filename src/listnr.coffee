addEvent = (el, type, handler) ->
  el.addEventListener(type, handler)


removeEvent = (el, type, handler) ->
  el.removeEventListener(type, handler)


keyCodeMap =
  8: 'backspace'
  9: 'tab'
  13: 'enter'
  16: 'shift'
  17: 'ctrl'
  18: 'alt'
  20: 'capslock'
  27: 'esc'
  32: 'space'
  33: 'pageup'
  34: 'pagedown'
  35: 'end'
  36: 'home'
  37: 'left'
  38: 'up'
  39: 'right'
  40: 'down'
  45: 'ins'
  46: 'del'
  91: 'meta'
  93: 'meta'
  224: 'meta'


class Context
  constructor: (@_listener) ->
    @_default = null
    @_map = {}
    @_comboBreaker = '+'

  activate: ->
    @_listener.activate(this)

  default: (callback) ->
    @_default = callback

  help: ->
    help = {}
    for own key, [_, desc] of @_map
      help[key] = desc
    help

  join: (combo) ->
    combo.join(@_comboBreaker)

  resolve: (combo) ->
    obj = @_map

    for key in combo
      break if not obj
      obj = obj[key]

    if not obj
      @_default
    else if obj instanceof Array
      obj[0]
    else
      true

  map: (combo, helpText, callback) ->
    if not callback
      callback = helpText
      helpText = null

    fn = => callback.apply(@_listener, arguments)
    obj = @_map

    [head..., tail] = combo.split(@_comboBreaker)
    obj = obj[key] or= {} for key in head
    obj[tail] = [fn, helpText]

    this

  unmap: (combo) ->
    delete @_map[combo]
    this


class @Listnr
  constructor: (options={}) ->
    @_contexts = default: new Context(this)
    @_active = @_contexts['default']
    @_combo = []
    @el = options.el or document.body
    addEvent(@el, 'keypress', => @_listener.apply(this, arguments))

  _listener: (event) ->
    keyCode = event.keyCode
    key = keyCodeMap[keyCode] or String.fromCharCode(keyCode)

    @_combo.push(key)
    handler = @_active.resolve(@_combo)

    if not handler
      @_combo = []
    else if handler instanceof Function
      handler(@_active.join(@_combo))

  activate: (ctx) ->
    ctx = @_contexts[ctx] if typeof ctx is 'string'
    @_active = ctx
    this

  addContext: (id) ->
    @_contexts[id] = new Context(this)

  default: (callback) ->
    @_active.default(callback)
    this

  help: ->
    @_active.help()

  map: ->
    @_active.map.apply(@_active, arguments)
    this

  reset: ->
    @_active = @_contexts['default']
    this

  unmap: (combo) ->
    @_active.unmap(combo)
    this
