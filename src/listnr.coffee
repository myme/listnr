addEvent = (el, type, handler) ->
  el.addEventListener(type, handler)

removeEvent = (el, type, handler) ->
  el.removeEventListener(type, handler)

class Listnr
  constructor: (options={}) ->
    @_map = {}
    @el = options.el or document.body

  add: (combo, callback) ->
    listener = @_map[combo] = =>
      callback.call(this, combo)
    addEvent(@el, 'keypress', listener)
    this

  remove: (combo) ->
    removeEvent(@el, 'keypress', @_map[combo])
    this

this.Listnr = Listnr
