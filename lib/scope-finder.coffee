require 'atom'


findByIndentation = (editor, tagstart) ->
    # Guess tag end by assuming both start and end lines use same indent
    lastline = editor.getLastBufferRow()
    tagindent = editor.indentationForBufferRow tagstart

    ended = false
    tagend = lastline
    for i in [tagstart + 1..lastline] when not ended
      text = editor.lineTextForBufferRow i
      if not text?
        # Skip when Atom cannot read any line from the Buffer
        continue

      trimmed = text.trim()
      if trimmed == ''
        # Blank line should not be considered as tag end line
        continue

      lineindent = editor.indentationForBufferRow i

      if lineindent <= tagindent
        ended = true
        tagend = i - 1

    # Strip trailing blank lines
    while editor.lineTextForBufferRow(tagend).trim() == ''
      tagend = tagend - 1

    tagend


findByCloseCurly = (editor, tagstart) ->
    # Guess tag end by assuming end curly use same indent as that of tag
    lastline = editor.getLastBufferRow()
    tagindent = editor.indentationForBufferRow tagstart

    ended = false
    tagend = lastline
    for i in [tagstart + 1..lastline] when not ended
      text = editor.lineTextForBufferRow i
      if not text?
        # Skip when Atom cannot read any line from the Buffer
        continue

      trimmed = text.trim()
      if trimmed == ''
        # Blank line should not be considered as tag end line
        continue

      lineindent = editor.indentationForBufferRow i

      if lineindent == tagindent && /^{.*/.test(trimmed)
        # Open curly should not be considered as tag end
        continue
      else if /^(public|protected|private):\s*/.test(trimmed)
        # Inheritance access control should not be considered as tag end
        continue

      if /^}/.test(trimmed)
        if lineindent == tagindent
          ended = true
          tagend = i  # Belongs to current scope
        else if lineindent < tagindent
          ended = true
          tagend = i - 1  # Belongs to outer scope
      else if lineindent <= tagindent
          ended = true
          tagend = i - 1  # End of scope without seeing close curly

    # Strip trailing blank lines
    while editor.lineTextForBufferRow(tagend).trim() == ''
      tagend = tagend - 1

    tagend


findByEndStmt = (editor, tagstart) ->
    # Guess tag end by assuming 'end' statement use same indent as that of tag
    lastline = editor.getLastBufferRow()
    tagindent = editor.indentationForBufferRow tagstart

    ended = false
    tagend = lastline
    for i in [tagstart + 1..lastline] when not ended
      text = editor.lineTextForBufferRow i
      if not text?
        # Skip when Atom cannot read any line from the Buffer
        continue

      trimmed = text.trim()
      if trimmed == ''
        # Blank line should not be considered as tag end line
        continue

      lineindent = editor.indentationForBufferRow i

      if /^end\s*/.test(trimmed)
        if lineindent == tagindent
          ended = true
          tagend = i
      else if lineindent <= tagindent
          ended = true
          tagend = i - 1  # End of scope without seeing end statement

    # Strip trailing blank lines
    while editor.lineTextForBufferRow(tagend).trim() == ''
      tagend = tagend - 1

    tagend


class Finder
  constructor: (editor) ->
    @editor = editor
    matches = @editor.getPath().match(/(\.[a-zA-Z0-9]+)$/)
    if matches?
      @fileext = matches[1].toLowerCase()
    else
      @fileext = ''

  guessedTagEndFrom: (tagstart) ->
    findFunc = switch @fileext
      when '.coffee', '.cpp', '.css', '.go', '.java', '.js', '.php'
        findByCloseCurly
      when '.rb'
        findByEndStmt
      when '.py'
        findByIndentation
      else
        findByIndentation

    tagend = findFunc @editor, tagstart

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
