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
      @ctagsStatusView.setText ''
      return

    path = editor.getPath()
    current = editor.getCursorBufferPosition()

    findTag = (tags) =>
      getIndent = (text) ->
        # FIXME: Respect current indentation settings of Atom
        text = text.replace(/^(\s*)(.*)/, '$1')
        text.length

      findParent = (parents) ->
        tagClosed = (lineno, tag_indent) ->
          if lineno == current.row
            return false

          closed = false
          for i in [lineno + 1..current.row] when not closed
            text = editor.lineTextForBufferRow i
            indent = getIndent text

            if indent == tag_indent
              closed = true

          return closed

        for [tag, type, lineno] in tags  # Already sorted by lineno DESC
          if lineno > current.row
            continue  # Tag later than current row would never be parent

          text = editor.lineTextForBufferRow lineno
          tag_indent = getIndent(text)

          if tagClosed(lineno, tag_indent)
            continue  # Tag already closed would never be parent

          return tag

      parent = findParent tags
      parent = if not parent? then 'global' else parent

      @ctagsStatusView.setText parent

    @ctags.getTags path, findTag, refresh_tags
