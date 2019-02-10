{CompositeDisposable} = require 'atom'

Q = null

CtagsStatusView = null

Cache = null
Finder = null
Generator = null


module.exports = CtagsStatus =
  ctagsStatusView: null
  subscriptions: null

  config:
    executablePath:
      title: 'exuberant-ctags Executable Path'
      description: 'The path to `ctags` executable, the vendored one of symbols-view package is used by default'
      type: 'string'
      default: ''
    ctagsTypes:
      title: 'Ctags type(s)'
      description: 'A list of CTags type(s) that could define a scope.'
      type: 'string'
      default: 'class,func,function,member,type,method,interface'
    statusbarPriority:
      title: 'Statusbar priority'
      description: 'The priority of the scope name on the status bar.
                    Lower priority leans toward the side.'
      type: 'integer'
      default: 1
      minimum: -1
    cacheSize:
      title: 'Cache size'
      description: 'Number of slots to hold Ctags cache in memory.'
      type: 'integer'
      default: 8
      minimum: 1
    outerScope:
      title: 'Show outer scope(s)'
      description: 'Show all scope(s) on current line.'
      type: 'boolean'
      default: false
    useIndentationFinder:
      title: 'Find scope range by indentation as default'
      description: 'By default, use indentation to find scope range
                    for unsupported languages. Otherwise, use the position of
                    the scope in the file to find the range.'
      type: 'boolean'
      default: true


  activate: (state) ->
    Q ?= require 'q'

    CtagsStatusView ?= require './ctags-status-view'

    Cache ?= require './cache'
    Finder ?= require './scope-finder'
    Generator ?= require './generator'

    cache_size = atom.config.get('ctags-status.cacheSize')

    @cache = new Cache(cache_size)
    @generator = new Generator
    @ctagsStatusView = new CtagsStatusView(state.ctagsStatusViewState)

    @subscriptions = new CompositeDisposable

    # Register config monitors
    @subscriptions.add atom.config.onDidChange 'ctags-status.statusbarPriority',
    ({newValue, oldValue}) =>
      priority = newValue

      @ctagsStatusView.unmount()
      @ctagsStatusView.mount(@statusBar, priority)

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
    @statusBar = null

    @cache.clear()
    @cache = null

    @generator.destruct()
    @generator = null

    Q = null

    CtagsStatusView = null

    Cache = null
    Finder = null
    Generator = null

  serialize: ->
    ctagsStatusViewState: @ctagsStatusView.serialize()

  consumeStatusBar: (statusBar) ->
    @statusBar = statusBar

    priority = atom.config.get('ctags-status.statusbarPriority')
    @ctagsStatusView.mount(@statusBar, priority)

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
      @ctagsStatusView.clear()
      return

    path = editor.getPath()
    if not path?
      @ctagsStatusView.clear()
      return

    finder = Finder.on(editor)

    findScope = (map) =>
      scopes = finder.getScopesFrom map
      scopes = if not scopes? then ['global'] else scopes

      @ctagsStatusView.clear()
      show_outer = atom.config.get('ctags-status.outerScope')
      if show_outer
        for scope in scopes
          @ctagsStatusView.addText scope
      else
        @ctagsStatusView.addText scopes[scopes.length-1]

    if refresh or not @cache.has path
      # Always set a blank map to prevent Ctags failure / no tag is found.
      @cache.set path, {}

      deferred = Q.defer()

      disposable = editor.getBuffer().onDidDestroy ->
        deferred.reject()

      @generator.generateTags path, (tags) ->
        deferred.resolve(tags)

      deferred.promise.fin ->
        disposable.dispose()

      deferred.promise.then (tags) =>
        filter = (tags) ->
          # Ignore un-interested tags
          do_ = (tag) ->
            interested = atom.config.get('ctags-status.ctagsTypes')
            interested = interested.split(',')

            if tag.type not in interested
              return null

            tag

          (do_(i) for i in tags when i?)

        dedup = (tags) ->
          # De-duplicate tag that has multiple types.
          # Keep the one which its name is the shortest.
          # Note, tags are sorted by start line ASC.
          # E.g.
          # "O.func" is a "method" and "func" is a "function" on the same line.
          # We keep "func".
          tags = (i for i in tags when i?)
          uniq = []

          i = 0
          while i < tags.length
            thisTag = tags[i]
            j = i + 1

            while j < tags.length
              checkTag = tags[j]
              if thisTag.start != checkTag.start
                break
              if thisTag.name.length > checkTag.name.length
                thisTag = checkTag
              j += 1

            uniq.push(thisTag)
            i = j

          uniq

        enrich = (tags) ->
          # Enrich tag info
          do_ = (tag) ->
            tagindent = editor.indentationForBufferRow tag.start
            tag.indent = tagindent

            tag

          (do_(i) for i in tags when i?)

        transform = (tags) ->
          # Find tag's end line
          use_indentation = atom.config.get('ctags-status.useIndentationFinder')
          tags = finder.estimateScopeRanges(tags)
          finder.refineScopeRanges(tags, use_indentation)

        tags = transform(enrich(dedup(filter(tags))))
        map = finder.scopeMapFrom tags

        @cache.set path, map
        findScope map
    else
      map = @cache.get path
      findScope map
