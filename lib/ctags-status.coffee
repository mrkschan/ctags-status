Ctags = require './ctags'
CtagsStatusView = require './ctags-status-view'
{CompositeDisposable} = require 'atom'

module.exports = CtagsStatus =
  ctagsStatusView: null
  subscriptions: null

  activate: (state) ->
    @ctags = new Ctags
    @ctagsStatusView = new CtagsStatusView(state.ctagsStatusViewState)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable
    @editor_subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.workspace.onDidChangeActivePaneItem =>
      @unsubscribeLastActiveEditor()
      @subscribeToActiveEditor()
      @toggle()

    @subscribeToActiveEditor()
    @toggle()

  deactivate: ->
    @unsubscribeLastActiveEditor()

    @subscriptions.dispose()
    @ctagsStatusView.destroy()

  serialize: ->
    ctagsStatusViewState: @ctagsStatusView.serialize()

  consumeStatusBar: (statusBar) ->
    @statusBar = statusBar.addLeftTile(item: @ctagsStatusView.getElement(), priority: 100)

  subscribeToActiveEditor: ->
    editor = atom.workspace.getActiveTextEditor()
    if not editor?
      return

    @editor_subscriptions.add editor.onDidChangeCursorPosition =>
      @toggle()

    @editor_subscriptions.add editor.onDidSave =>
      @toggle(true)

  unsubscribeLastActiveEditor: ->
    @editor_subscriptions.dispose()

  toggle: (refresh_tags=false) ->
    editor = atom.workspace.getActiveTextEditor()
    if not editor?
      @ctagsStatusView.getElement().textContent = ''
      return

    path = editor.getPath()
    pos = editor.getCursorBufferPosition()
    thisLine = pos.row + 1

    findTag = (tags) =>
      # tags: [[tag, type, lineno], ...], sorted by lineno ASC
      # FIXME: Support nested Ctag by looking at indentation
      parents = (tag for [tag, type, lineno] in tags when lineno <= thisLine)
      parent = parents[-1..][0]

      if not parent?
        parent = 'global'

      @ctagsStatusView.getElement().textContent = "[#{parent}]"

    @ctags.getTags path, findTag, refresh_tags
