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
    indent = getIndent text

    if indent == tag_indent
      closed = true

  return closed

module.exports =
  find: (parents) ->
    editor = atom.workspace.getActiveTextEditor()
    current = editor.getCursorBufferPosition()

    for [tag, type, lineno] in parents  # Already sorted by lineno DESC
      if lineno > current.row
        continue  # Tag later than current row would never be parent

      text = editor.lineTextForBufferRow lineno
      tag_indent = getIndent text

      if tagClosed(editor, current, lineno, tag_indent)
        continue  # Tag already closed would never be parent

      return tag
