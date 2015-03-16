CtagsStatusView = require './ctags-status-view'
{CompositeDisposable} = require 'atom'

module.exports = CtagsStatus =
  ctagsStatusView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @ctagsStatusView = new CtagsStatusView(state.ctagsStatusViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @ctagsStatusView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'ctags-status:toggle': => @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @ctagsStatusView.destroy()

  serialize: ->
    ctagsStatusViewState: @ctagsStatusView.serialize()

  toggle: ->
    console.log 'CtagsStatus was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
