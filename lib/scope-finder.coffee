require 'atom'

class Finder
  constructor: (editor) ->
    @editor = editor

  guessedTagEndFrom: (tagstart) ->
    # Guess tag end line by assuming both start and end lines use same indent
    lastline = @editor.getLastBufferRow()
    tagindent = @editor.indentationForBufferRow tagstart

    ended = false
    tagend = lastline
    for i in [tagstart + 1..lastline] when not ended
      text = @editor.lineTextForBufferRow i
      if not text?
        # Skip when Atom cannot read any line from the Buffer
        continue

      trimmed = text.trim()
      if trimmed == '' or trimmed.replace(/^{/, '') == ''
        # Blank line and open curly should not be considered as tag end line
        continue

      lineindent = @editor.indentationForBufferRow i

      if lineindent <= tagindent
        ended = true
        if /^}/.test(trimmed)  # For languages using '}' to close a scope
          tagend = i
        else  # For languages using indentation to close a scope
          tagend = i - 1

    tagend

  scopeMapFrom: (tags) ->
    map = {}

    for info in tags  # tags sorted by DESC
      [tag, tagstart, tagend] = info
      for i in [tagstart..tagend]
        if not map[i]?
          map[i] = []
        map[i].push(tag)

    map

  findScopeFrom: (map) ->
    current = @editor.getCursorBufferPosition()
    scopes = map[current.row]
    if not scopes?
      return

    scopes[0]  # Inner scope at the front, refer to buildScopeMap()


module.exports =
  on: (editor) ->
    new Finder(editor)
