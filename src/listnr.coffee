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
    @_comboBreaker = ' '
    @_comboSplitter = '|'

  activate: ->
    @_listener.activate(this)

  default: (callback) ->
    @_default = callback

  _help: (map, path=[]) ->
    help = {}

    for own key, value of map
      _path = path.concat(key)
      if value instanceof Array
        [_, desc] = value
        help[@join(_path)] = desc
      else
        for own _key, _value of @_help(value, _path)
          help[_key] = _value

    help

  help: (combo) ->
    help = @_help(@_map)
    if not combo
      help
    else
      help[combo]

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
    for combo in combo.split(@_comboSplitter)
      if not callback
        callback = helpText
        helpText = null

      fn = => callback.apply(@_listener, arguments)
      obj = @_map

      [head..., tail] = @split(combo)
      obj = obj[key] or= {} for key in head
      obj[tail] = [fn, helpText]

    this

  split: (combo) ->
    combo.split(@_comboBreaker)

  unmap: (combo) ->
    for combo in combo.split(@_comboSplitter)
      delete @_map[combo]
    this


class @Listnr
  constructor: (options={}) ->
    @_contexts = default: new Context(this)
    @_active = @_contexts['default']
    @_always = null
    @_combo = []
    @el = options.el or document.body
    addEvent(@el, 'keypress', => @_listener.apply(this, arguments))

  _listener: (event) ->
    keyCode = event.keyCode
    key = keyCodeMap[keyCode] or String.fromCharCode(keyCode)

    @_combo.push(key)
    always = @_always
    combo = @_active.join(@_combo)
    handler = @_active.resolve(@_combo)

    always(combo) if always instanceof Function

    if not handler
      @_clearCombo()
    else if handler instanceof Function
      handler(combo)
      @_clearCombo()

  _clearCombo: ->
    @_combo = []

  activate: (ctx) ->
    ctx = @_contexts[ctx] if typeof ctx is 'string'
    @_active = ctx
    this

  addContext: (id) ->
    @_contexts[id] = new Context(this)

  always: (callback) ->
    @_always = callback
    this

  default: (callback) ->
    @_active.default(callback)
    this

  help: (combo) ->
    @_active.help(combo)

  map: ->
    @_active.map.apply(@_active, arguments)
    this

  reset: ->
    @_active = @_contexts['default']
    this

  unmap: (combo) ->
    @_active.unmap(combo)
    this
