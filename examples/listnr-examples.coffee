Listnr = @Listnr

createEl = (tag) ->
  document.createElement(tag)

div = createEl('div')
div.innerHTML = """
  <dl>
    <dt>Context:</dt>
    <dd id="context"></dd>
    <dt>Action:</dt>
    <dd id="action"></dd>
    <dt>Help text:</dt>
    <dd id="help-text">NA</dd>
    <dt>Key Code:</dt>
    <dd id="key-code">NA</dd>
  </dl>
  <pre id="help">
  </pre>
"""
document.body.appendChild(div)

listnr = new Listnr()


setHTML = (id, html) ->
  document
    .getElementById(id)
    .innerHTML = html


setContext = (ctx) -> (combo) ->
  updateHelp(combo)
  listnr.activate(ctx)
  setHTML('action', "Switching context to '#{ctx}'")
  setHTML('context', ctx)
  setHTML('help', JSON.stringify(listnr.help(), null, 2))


updateHelp = (combo) ->
  help = listnr.help(combo) if combo
  setHTML('help-text', help or 'NA')


matchingHandler = (combo) ->
  setHTML('action', "Has mapping for '#{combo}'")
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
  .map('a', 'Mapping for "a"', matchingHandler)
  .map('b c', 'Mapping for "b c"', matchingHandler)
  .map('e|f', 'Mapping for foo', matchingHandler)
  .map('c', 'Switch to menu context', setContext('menu'))
  .default(defaultHandler)
  .addContext('menu')
  .map('b', 'Mapping for "b"', matchingHandler)
  .map('d', 'Switch to default context', setContext('default'))
  .default(defaultHandler)


setContext('default')()
