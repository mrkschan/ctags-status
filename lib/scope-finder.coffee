require 'atom'


findByScopePosition = (editor, tagstart, lastline, tagindent, excludes=[]) ->
  # Guess tag end by using the estimated scope position
  tagend = lastline

  # Strip trailing blank lines
  while editor.lineTextForBufferRow(tagend).trim() == ''
    tagend = tagend - 1

  tagend


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
    /^(public|protected|private):\s*/,
    # Exclude macros starting with '#'
    /^#/
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
  '.htm': findByScopePosition,
  '.html': findByScopePosition,
  '.hxx': findCPPClose,
  '.h++': findCPPClose,
  '.java': findByCloseCurly,
  '.js': findByCloseCurly,
  '.less': findByCloseCurly,
  '.php': findByCloseCurly,
  '.pl': findByCloseCurly,
  '.rb': findByEndStmt,
  '.sass': findByIndentation,
  '.scss': findByCloseCurly,
  '.py': findByIndentation,
  '.xhtml': findByScopePosition,
  '.xml': findByScopePosition,


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

    # All tags end at the last line before making any estimation.
    for tag in tags
      tag.end = lastline
      lastlines_idx[tag.indent] ?= lastline

    # Estimate
    for idx in [tags.length-1 .. 1] by -1
      do (idx) ->
        last_tag = tags[idx - 1]
        this_tag = tags[idx]

        if last_tag.indent < this_tag.indent
          # this_tag is nested inside last_tag.
          # last_tag should end at the end line of the deepest nested scope,
          # which is the line right before the next same indent level tag.
          estimated = lastlines_idx[last_tag.indent]
        else
          # this_tag is starting a scope which is not nested by last_tag.
          # last_tag should end before this_tag.
          estimated = this_tag.start - 1
          lastlines_idx[this_tag.indent] = estimated
          lastlines_idx[last_tag.indent] = estimated

        last_tag.end = estimated

    tags

  makeScopeRanges: (tags, use_indentation=true) ->
    # Return scope ranges by finding end line of each scope.
    if use_indentation
      defaultFinder = findByIndentation
    else
      defaultFinder = findByScopePosition

    findTagEnd = tagEndFinders[@fileext] || defaultFinder

    for tag in tags
      do (tag) =>
        tag.end = findTagEnd @editor, tag.start, tag.end, tag.indent

    tags

  scopeMapFrom: (tags) ->
    map = {}

    for tag in tags  # tags sorted by start line ASC
      for i in [tag.start..tag.end]
        if not map[i]?
          map[i] = []
        map[i].push(tag.name)

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
