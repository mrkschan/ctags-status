module.exports =
class CtagsStatusView
  constructor: (serializeState) ->
    # Create root element
    @element = document.createElement('span')
    @element.classList.add('ctags-status')

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  getElement: ->
    @element
