Ctags = require './ctags'
CtagsStatusView = require './ctags-status-view'

{CompositeDisposable, Task} = require 'atom'
Q = require 'q'

module.exports = CtagsStatus =
  ctagsStatusView: null
  subscriptions: null

  activate: (state) ->
    Cache = require './ctags-cache'
    @finder = require './scope-finder'

    @cache = new Cache
    @ctags = new Ctags
    @ctagsStatusView = new CtagsStatusView(state.ctagsStatusViewState)

    @subscriptions = new CompositeDisposable
    @editor_subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.workspace.onDidChangeActivePaneItem =>
      @unsubscribeLastActiveEditor()
      @subscribeToActiveEditor()
      @toggle()

    @subscriptions.add atom.workspace.observeTextEditors (editor) =>
      disposable = editor.onDidDestroy =>
        @cache.remove editor.getPath()
        disposable.dispose()

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

    @editor_subscriptions.add editor.onDidChangeCursorPosition (evt) =>
      last_pos = evt.oldBufferPosition
      this_pos = evt.newBufferPosition

      if last_pos.row == this_pos.row
        return

      if @countdown?
        @countdown.terminate()

      src = require.resolve('./countdown-handler.coffee')
      @countdown = Task.once src, 30, =>
        @countdown = undefined

      @countdown.on 'finish', (data) =>
        @toggle()

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

    findScope = (tags) =>
      parent = @finder.find tags
      parent = if not parent? then 'global' else parent

      @ctagsStatusView.setText parent

    if refresh or not @cache.has path
      @ctags.generateTags path, (tags) =>
        @cache.add path, tags
        findScope tags
    else
      tags = @cache.get path
      findScope tags
