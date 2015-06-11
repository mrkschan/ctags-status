require 'atom'


findByIndentation = (editor, tagstart, lastline, tagindent, excludes=[]) ->
  # Guess tag end by assuming both start and end lines use same indent
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

    is_excluded = false
    if lineindent == tagindent
      for re in excludes when not is_excluded
        is_excluded = re.test(trimmed)

    if is_excluded
      continue

    lineindent = editor.indentationForBufferRow i

    if lineindent <= tagindent
      ended = true
      tagend = i - 1

  # Strip trailing blank lines
  while editor.lineTextForBufferRow(tagend).trim() == ''
    tagend = tagend - 1

  tagend


findByCloseCurly = (editor, tagstart, lastline, tagindent, excludes=[]) ->
  # Guess tag end by assuming end curly use same indent as that of tag
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

    is_excluded = false
    if lineindent == tagindent
      for re in excludes when not is_excluded
        is_excluded = re.test(trimmed)

    if is_excluded
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


findByEndStmt = (editor, tagstart, lastline, tagindent, excludes=[]) ->
  # Guess tag end by assuming 'end' statement use same indent as that of tag
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

    is_excluded = false
    if lineindent == tagindent
      for re in excludes when not is_excluded
        is_excluded = re.test(trimmed)

    if is_excluded
      continue

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


findCPPClose = (editor, tagstart, lastline, tagindent) ->
  excludes = [
    # Inheritance access control should be excluded as tag end
    /^(public|protected|private):\s*/
  ]
  findByCloseCurly(editor, tagstart, lastline, tagindent, excludes)


tagEndFinders =
  '.c': findCPPClose,
  '.cc': findCPPClose,
  '.coffee': findByCloseCurly,
  '.cpp': findCPPClose,
  '.css': findByCloseCurly,
  '.cxx': findCPPClose,
  '.c++': findCPPClose,
  '.go': findByCloseCurly,
  '.h': findCPPClose,
  '.hh': findCPPClose,
  '.hpp': findCPPClose,
  '.hxx': findCPPClose,
  '.h++': findCPPClose,
  '.java': findByCloseCurly,
  '.js': findByCloseCurly,
  '.php': findByCloseCurly,
  '.rb': findByEndStmt,
  '.py': findByIndentation,


class Finder
  constructor: (editor) ->
    @editor = editor
    matches = @editor.getPath().match(/(\.[a-zA-Z0-9]+)$/)
    if matches?
      @fileext = matches[1].toLowerCase()
    else
      @fileext = ''

  estimateScopeRanges: (tags) ->
    # Make estimation by scope position.
    # Each scope ends right before the start of the next.
    # Though, outer nested scopes use the end line of its deepest nested one.
    # Note: Tags should be already sorted in ASC order by start line.
    lastline = @editor.getLastBufferRow()
    lastlines_idx = {}  # lastline of each indent level.

    # All indent levels end at the last line before making any estimation.
    for [..., indent] in tags
      lastlines_idx[indent] ?= lastline

    # Init
    do_ = (i) ->
      [tag, tagstart, tagindent] = i
      [tag, tagstart, lastline, tagindent]
    tags_ = (do_(i) for i in tags)

    # Estimate
    for idx in [tags_.length-1 .. 1] by -1
      do (idx) ->
        [last_tag, last_start, last_end, last_indent] = tags_[idx - 1]
        [this_tag, this_start, this_end, this_indent] = tags_[idx]

        if last_indent < this_indent
          # this_tag is nested inside last_tag.
          # last_tag should end at the end line of the deepest nested scope,
          # which is the line right before the next same indent level tag.
          last_end = lastlines_idx[last_indent]
        else
          # this_tag is starting a scope which is not nested by last_tag.
          # last_tag should end before this_tag.
          last_end = this_start - 1
          lastlines_idx[this_indent] = last_end
          lastlines_idx[last_indent] = last_end

        tags_[idx - 1] = [last_tag, last_start, last_end, last_indent]

    tags_

  makeScopeRanges: (tags) ->
    # Return scope ranges by finding end line of each scope.
    for idx in [0 .. tags.length - 1]
      do (idx) =>
        [tag, tagstart, tagend, tagindent] = tags[idx]
        tagend = @findScopeEnd(tagstart, tagend, tagindent)
        tags[idx] = [tag, tagstart, tagend]

    tags

  findScopeEnd: (tagstart, tagend_estimate, tagindent) ->
    findFunc = tagEndFinders[@fileext] || findByIndentation
    tagend = findFunc @editor, tagstart, tagend_estimate, tagindent

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
