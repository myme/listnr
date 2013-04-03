addEvent = (el, type, handler) ->
  el.addEventListener(type, handler)

removeEvent = (el, type, handler) ->
  el.removeEventListener(type, handler)

class @Listnr
  constructor: (options={}) ->
    @_map = {}
    @el = options.el or document.body
    addEvent(@el, 'keypress', => @listener.apply(this, arguments))

  listener: (event) ->
    combo = String.fromCharCode(event.keyCode)
    handler = @_map[combo]
    handler() if handler

  map: (combo, callback) ->
    @_map[combo] = => callback.call(this)
    this

  unmap: (combo) ->
    delete @_map[combo]
    this
