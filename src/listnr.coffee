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
