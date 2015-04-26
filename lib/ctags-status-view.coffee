module.exports =
class CtagsStatusView
  constructor: (serializeState) ->
    # Create root element
    @element = document.createElement('div')
    @element.classList.add('ctags-status', 'func-info', 'inline-block')

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @unmount()
    @element.remove()

  mount: (statusBar, priority) ->
    @statusBarTile = statusBar.addLeftTile(item: @element, priority: priority)

  unmount: ->
    @statusBarTile?.destroy()
    @statusBarTile = null

  getElement: ->
    @element

  setText: (text)  ->
    if text == ''
      @element.textContent = ''
    else
      @element.textContent = "[#{text}]"
