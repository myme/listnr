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
  </dl>
  <pre id="help">
  </pre>
"""
document.body.appendChild(div)

listnr = new Listnr()


setContext = (ctx) ->
  listnr.activate(ctx)
  document
    .getElementById('action')
    .innerHTML = "Switching context to '#{ctx}'"
  document
    .getElementById('context')
    .innerHTML = ctx
  document
    .getElementById('help')
    .innerHTML = JSON.stringify(listnr.help(), null, 2)


matchingHandler = (combo) ->
  document
    .getElementById('action')
    .innerHTML = "Has mapping for '#{combo}'"


defaultHandler = (combo) ->
  document
    .getElementById('action')
    .innerHTML = "No mapping for '#{combo}'"


listnr
  .map('a', 'Mapping for "a"', matchingHandler)
  .map('b c', 'Mapping for "b c"', matchingHandler)
  .map('c', 'Switch to menu context', -> setContext('menu'))
  .default(defaultHandler)
  .addContext('menu')
  .map('b', 'Mapping for "b"', matchingHandler)
  .map('d', 'Switch to default context', -> setContext('default'))
  .default(defaultHandler)


setContext('default')
