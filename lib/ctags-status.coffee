Ctags = require './ctags'
CtagsStatusView = require './ctags-status-view'

{CompositeDisposable} = require 'atom'
Q = require 'q'

module.exports = CtagsStatus =
  ctagsStatusView: null
  subscriptions: null

  activate: (state) ->
    @finder = require './scope-finder'
    @ctags = new Ctags
    @ctagsStatusView = new CtagsStatusView(state.ctagsStatusViewState)

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
    @statusBar = statusBar.addLeftTile(item: @ctagsStatusView.getElement(),
                                       priority: 100)

  subscribeToActiveEditor: ->
    editor = atom.workspace.getActiveTextEditor()
    if not editor?
      return

    @editor_subscriptions.add editor.onDidChangeCursorPosition =>
      if @deferred? and @deferred.promise.isPending()
        @deferred.reject()

      @deferred = Q.defer()

      @deferred.promise.then =>
        @toggle()

      Q.delay(300).then =>
        @deferred.resolve()

    @editor_subscriptions.add editor.onDidSave =>
      @toggle(true)

  unsubscribeLastActiveEditor: ->
    @editor_subscriptions.dispose()

  toggle: (refresh=false) ->
    editor = atom.workspace.getActiveTextEditor()
    if not editor?
      @ctagsStatusView.setText ''
      return

    path = editor.getPath()

    findTag = (tags) =>
      parent = @finder.find tags
      parent = if not parent? then 'global' else parent

      @ctagsStatusView.setText parent

    @ctags.getTags path, findTag, refresh
