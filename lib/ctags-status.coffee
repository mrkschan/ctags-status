{CompositeDisposable} = require 'atom'

Ctags = null
CtagsStatusView = null

Cache = null
Finder = null

module.exports = CtagsStatus =
  ctagsStatusView: null
  subscriptions: null

  activate: (state) ->
    Ctags ?= require './ctags'
    CtagsStatusView ?= require './ctags-status-view'

    Cache ?= require './ctags-cache'
    Finder ?= require './scope-finder'

    @cache = new Cache
    @ctags = new Ctags
    @ctagsStatusView = new CtagsStatusView(state.ctagsStatusViewState)

    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.workspace.observeActivePaneItem =>
      @unsubscribeLastActiveEditor()
      @subscribeToActiveEditor()
      @toggle()

    @subscriptions.add atom.workspace.observeTextEditors (editor) =>
      disposable = editor.onDidDestroy =>
        path = editor.getPath()

        if path?
          @cache.remove path

        disposable.dispose()

  deactivate: ->
    @unsubscribeLastActiveEditor()
    @subscriptions.dispose()

    @ctagsStatusView.destroy()

    @cache.clear()

    Ctags = null
    CtagsStatusView = null

    Cache = null
    Finder = null

  serialize: ->
    ctagsStatusViewState: @ctagsStatusView.serialize()

  consumeStatusBar: (statusBar) ->
    @statusBar = statusBar.addLeftTile(item: @ctagsStatusView.getElement(),
                                       priority: 100)

  subscribeToActiveEditor: ->
    editor = atom.workspace.getActiveTextEditor()
    if not editor?
      return

    @editor_subscriptions = new CompositeDisposable

    @editor_subscriptions.add editor.onDidChangeCursorPosition (evt) =>
      last_pos = evt.oldBufferPosition
      this_pos = evt.newBufferPosition

      if last_pos.row == this_pos.row
        return

      @toggle()

    @editor_subscriptions.add editor.onDidSave =>
      @toggle(true)

  unsubscribeLastActiveEditor: ->
    if @editor_subscriptions?
      @editor_subscriptions.dispose()

    @editor_subscriptions = null

  toggle: (refresh=false) ->
    editor = atom.workspace.getActiveTextEditor()
    if not editor?
      @ctagsStatusView.setText ''
      return

    path = editor.getPath()
    if not path?
      @ctagsStatusView.setText ''
      return

    findScope = (map) =>
      parent = Finder.find map
      parent = if not parent? then 'global' else parent

      @ctagsStatusView.setText parent

    if refresh or not @cache.has path
      # Always add a blank map to prevent Ctags failure / no tag is found.
      @cache.add path, {}

      @ctags.generateTags path, (tags) =>
        filter = (info) ->
          # Ignore un-interested tags
          # I/O: (Tags, Type, Start Line) -> (Tags, Start Line)
          interested = ['class', 'func', 'function', 'member']
          [tag, type, tagstart] = info

          if type not in interested
            return

          [tag, tagstart]

        explode = (info) =>
          # Guess tag's end line
          # I/O: (Tags, Start Line) -> (Tags, Start Line, End Line)
          [tag, tagstart] = info
          tagend = Finder.guessedTagEnd(tagstart)
          [tag, tagstart, tagend]

        tags = (filter(info) for info in tags)
        tags = (explode(info) for info in tags when info?)

        map = Finder.buildScopeMap(tags)

        @cache.add path, map
        findScope map
    else
      map = @cache.get path
      findScope map
