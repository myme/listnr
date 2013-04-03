addEvent = (el, type, handler) ->
  el.addEventListener(type, handler)

removeEvent = (el, type, handler) ->
  el.removeEventListener(type, handler)

class Context
  constructor: (@_listener) ->
    @_map = {}

  resolve: (combo) ->
    @_map[combo]

  map: (combo, callback) ->
    @_map[combo] = => callback.call(@_listener)
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
    handler() if handler

  addContext: (id) ->
    @_contexts[id] = new Context(this)

  map: (combo, callback) ->
    @_active.map(combo, callback)
    this

  unmap: (combo) ->
    @_active.unmap(combo)
    this
