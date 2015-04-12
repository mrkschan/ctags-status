{BufferedProcess} = require 'atom'

module.exports =
class Ctags
  parseTags: (lines) ->
    parse = (line) ->
      line = line.trim()
      if line == ''
        return []

      parts = line.split '\t'
      [tag, path, snippet, type, lineno] = parts
      lineno = lineno.replace 'line:', ''
      lineno = parseInt lineno, 10
      lineno = lineno - 1  # Use zero based

      [tag, type, lineno]

    tags = (parse line for line in lines.split '\n')
    (tag for tag in tags when tag.length > 0)

  generateTags: (path, callback) ->
    presets = require.resolve('./.ctagsrc')

    command = 'ctags'

    args = []
    args.push("--options=#{presets}", '--fields=+KSn', '--excmd=p')
    args.push('-R', '-f', '-', path)

    stdout = (lines) =>
      tags = @parseTags lines
      tags.sort((x, y) -> y[2] - x[2])  # Sort lineno by desc order

      callback tags

    stderr = (lines) ->
      console.warn lines

    subprocess = new BufferedProcess({command, args, stdout, stderr})
