module.exports =
class CtagsStatusView
  constructor: (serializeState) ->
    # Create root element
    @element = document.createElement('div')
    @element.classList.add('ctags-status', 'func-info', 'inline-block')

    @container = document.createElement('div')

    @outer = document.createElement('div')
    @outer.classList.add('ellipsis', 'reverse-ellipsis')
    @element.appendChild(@outer)
    @outer.appendChild(@container)

    # @element.classList.add('reverse-ellipsis')
    # @element.appendChild(@container)

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @unmount()
    @container.remove()
    @outer.remove()
    @element.remove()

  mount: (statusBar, priority) ->
    @statusBarTile = statusBar.addLeftTile(item: @element, priority: priority)

  unmount: ->
    @statusBarTile?.destroy()
    @statusBarTile = null

  getElement: ->
    @element

  clear: ->
    while @container.firstChild?
      @container.removeChild(@container.firstChild)

    @element.classList.add 'blank'

  addText: (text) ->
    @element.classList.remove 'blank'

    span = document.createElement('span')
    span.textContent = text
    @container.appendChild(span)
