addEvent = (el, type, handler) ->
  el.addEventListener(type, handler)

removeEvent = (el, type, handler) ->
  el.removeEventListener(type, handler)

class Context
  constructor: (@_listener) ->
    @_default = null
    @_map = {}

  activate: ->
    @_listener.activate(this)

  default: (callback) ->
    @_default = callback

  resolve: (combo) ->
    @_map[combo] or @_default

  map: (combo, callback) ->
    @_map[combo] = => callback.apply(@_listener, arguments)
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

  map: (combo, callback) ->
    @_active.map(combo, callback)
    this

  reset: ->
    @_active = @_contexts['default']
    this

  unmap: (combo) ->
    @_active.unmap(combo)
    this
