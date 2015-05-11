{BufferedProcess} = require 'atom'

module.exports =
class Ctags
  parseTags: (lines) ->
    parse = (line) ->
      line = line.trim()
      if line == ''
        return []

      # Format: tag_name<TAB>file_name<TAB>ex_cmd;"<TAB>extension_fields
      [lpart, rpart] = line.split ';"\t'
      [tag_name, file_name, pattern...] = lpart.split '\t'
      [tag_type, line_no] = rpart.split '\t'

      line_no = line_no.replace 'line:', ''
      line_no = parseInt line_no, 10
      line_no = line_no - 1  # Use zero based

      [tag_name, tag_type, line_no]

    tags = (parse line for line in lines.split '\n')
    (tag for tag in tags when tag.length > 0)

  generateTags: (path, callback) ->
    presets = require.resolve('./.ctagsrc')

    command = 'ctags'

    args = []
    args.push("--options=#{presets}", '--fields=+Kn', '--excmd=p')
    args.push('-R', '-f', '-', path)

    stdout = (lines) =>
      tags = @parseTags lines
      tags.sort((x, y) -> x[2] - y[2])  # Sort line_no by asc order

      callback tags

    stderr = (lines) ->
      console.warn lines

    subprocess = new BufferedProcess({command, args, stdout, stderr})
