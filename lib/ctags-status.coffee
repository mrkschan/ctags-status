Ctags = require './ctags'
CtagsStatusView = require './ctags-status-view'
{CompositeDisposable} = require 'atom'

module.exports = CtagsStatus =
  ctagsStatusView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @ctags = new Ctags
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

    editor = atom.workspace.getActiveTextEditor()
    path = editor.getPath()

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
      @ctags.generateTagFile path
