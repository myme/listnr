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
"""
document.body.appendChild(div)

listnr = new Listnr()

setContext = (ctx) ->
  document
    .getElementById('action')
    .innerHTML = "Switching context to '#{ctx}'"
  document
    .getElementById('context')
    .innerHTML = ctx
  listnr.activate(ctx)

matchingHandler = (combo) ->
  document
    .getElementById('action')
    .innerHTML = "Has mapping for '#{combo}'"

defaultHandler = (combo) ->
  document
    .getElementById('action')
    .innerHTML = "No mapping for '#{combo}'"

listnr
  .map('a', matchingHandler)
  .map('c', -> setContext('context'))
  .default(defaultHandler)
  .addContext('context')
  .map('b', matchingHandler)
  .map('d', -> setContext('default'))
  .default(defaultHandler)

setContext('default')
