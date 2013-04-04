Listnr = @Listnr

createEl = (tag) ->
  document.createElement(tag)


listnr = new Listnr()


setHTML = (el, html) ->
  if typeof el is 'string'
    el = document.getElementById(el)
  el.innerHTML = html


always = (combo) ->
  setHTML('combo', combo)


setContext = (ctx) -> (combo) ->
  updateHelp(combo)
  listnr.activate(ctx)

  setHTML('action', "Switching context to '#{ctx}'")
  setHTML('context', ctx)

  do ->
    dl = document.getElementById('help')
    dl.innerHTML = ''

    for own key, value of listnr.help()
      dt = createEl('dt')
      dd = createEl('dd')

      setHTML(dt, key)
      setHTML(dd, value)

      dl.appendChild(dt)
      dl.appendChild(dd)


updateHelp = (combo) ->
  help = listnr.help(combo) if combo
  setHTML('help-text', help or 'NA')


matchingHandler = (combo) ->
  setHTML('action', "Map handler for '#{combo}'")
  updateHelp(combo)


defaultHandler = (combo) ->
  setHTML('action', "No mapping for '#{combo}'")
  updateHelp(combo)


_listener = listnr._listener
listnr._listener = (event) ->
  setHTML('key-code', event.keyCode)
  console.log(event)
  _listener.apply(listnr, arguments)


listnr
  .always(always)
  .map('a', 'Mapping for "a"', matchingHandler)
  .map('b c', 'Mapping for "b c"', matchingHandler)
  .map('e|f', 'Mapping for foo', matchingHandler)
  .map('c', 'Switch to menu context', setContext('menu'))
  .default(defaultHandler)
  .addContext('menu')
  .map('b', 'Mapping for "b"', matchingHandler)
  .map('d', 'Switch to default context', setContext('default'))
  .map('up', 'Mapping for up key', matchingHandler)
  .default(defaultHandler)


setContext('default')()
