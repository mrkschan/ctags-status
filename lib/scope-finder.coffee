require 'atom'

getIndent = (text) ->
  # FIXME: Respect current indentation settings of Atom
  text = text.replace(/^(\s*)(.*)/, '$1')
  text.length

tagClosed = (editor, current, lineno, tag_indent) ->
  if lineno == current.row
    return false

  closed = false
  for i in [lineno + 1..current.row] when not closed
    text = editor.lineTextForBufferRow i
    trimmed = text.trim()
    if trimmed == '' or trimmed.replace(/^{/, '') == ''
      # Blank line and open curly should not be used as closed tag
      continue

    indent = getIndent text

    if indent == tag_indent
      closed = true

  return closed

module.exports =
  find: (parents) ->
    editor = atom.workspace.getActiveTextEditor()
    current = editor.getCursorBufferPosition()

    included_types = ['class', 'func', 'function']

    for [tag, type, lineno] in parents  # Already sorted by lineno DESC
      if lineno > current.row
        continue  # Tag later than current row would never be parent

      if type not in included_types
        continue

      text = editor.lineTextForBufferRow lineno
      tag_indent = getIndent text

      if tagClosed(editor, current, lineno, tag_indent)
        continue  # Tag already closed would never be parent

      return tag
