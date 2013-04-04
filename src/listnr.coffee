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

  activate: ->
    @_listener.activate(this)

  default: (callback) ->
    @_default = callback

  help: ->
    help = {}
    for own key, [_, desc] of @_map
      help[key] = desc
    help

  resolve: (combo) ->
    @_map[combo]?[0] or @_default

  map: (combo, helpText, callback) ->
    if not callback
      callback = helpText
      helpText = null
    fn = => callback.apply(@_listener, arguments)
    @_map[combo] = [fn, helpText]
    this

  unmap: (combo) ->
    delete @_map[combo]
    this


class @Listnr
  constructor: (options={}) ->
    @_contexts = default: new Context(this)
    @_active = @_contexts['default']
    @el = options.el or document.body
    addEvent(@el, 'keypress', => @listener.apply(this, arguments))

  listener: (event) ->
    combo = String.fromCharCode(event.keyCode)
    handler = @_active.resolve(combo)
    handler(combo) if handler

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
