require 'atom'

module.exports =
  guessedTagEnd: (tagstart) ->
    # Guess tag end line by assuming both start and end lines use same indent
    editor = atom.workspace.getActiveTextEditor()
    lastline = editor.getLastBufferRow()

    tagindent = editor.indentationForBufferRow tagstart

    ended = false
    tagend = lastline
    for i in [tagstart + 1..lastline] when not ended
      text = editor.lineTextForBufferRow i
      trimmed = text.trim()
      if trimmed == '' or trimmed.replace(/^{/, '') == ''
        # Blank line and open curly should not be considered as tag end line
        continue

      lineindent = editor.indentationForBufferRow i

      if lineindent == tagindent
        ended = true
        if /^}/.test(trimmed)  # For languages using '}' to close a scope
          tagend = i
        else  # For languages using indentation to close a scope
          tagend = i - 1

    tagend

  buildScopeMap: (tags) ->
    map = {}

    for info in tags  # tags sorted by DESC
      [tag, type, tagstart, tagend] = info
      for i in [tagstart..tagend]
        if not map[i]?
          map[i] = []
        map[i].push([tag, type])

    map

  find: (map) ->
    editor = atom.workspace.getActiveTextEditor()
    current = editor.getCursorBufferPosition()

    included_types = ['class', 'func', 'function', 'member']

    scopes = map[current.row]
    if not scopes?
      return undefined

    for [tag, type] in scopes  # Inner scope in the front
      if type not in included_types
        continue

      return tag

    undefined
