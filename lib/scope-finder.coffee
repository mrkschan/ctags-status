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
      if trimmed == ''
        # Blank line should not be considered as tag end line
        continue

      lineindent = @editor.indentationForBufferRow i

      if lineindent == tagindent && /^{.*/.test(trimmed)
        # Open curly should not be considered as tag end line
        continue

      if lineindent <= tagindent
        ended = true
        if /^}/.test(trimmed)  # For langs using '}' to close a scope
          tagend = i
        else if /^end\s*/.test(trimmed)  # For langs using 'end' to close a scope
          tagend = i
        else  # For languages using indentation to close a scope
          tagend = i - 1

    # Strip trailing blank lines
    while @editor.lineTextForBufferRow(tagend).trim() == ''
      tagend = tagend - 1

    tagend

  scopeMapFrom: (tags) ->
    map = {}

    for info in tags  # tags sorted by tagstart ASC
      [tag, tagstart, tagend] = info
      for i in [tagstart..tagend]
        if not map[i]?
          map[i] = []
        map[i].push(tag)

    map

  getScopesFrom: (map) ->
    current = @editor.getCursorBufferPosition()
    scopes = map[current.row]
    if not scopes?
      return

    scopes  # Inner scope at last, refer to scopeMapFrom()


module.exports =
  on: (editor) ->
    new Finder(editor)
