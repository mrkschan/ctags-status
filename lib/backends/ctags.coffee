{BufferedProcess} = require 'atom'

module.exports =
class Ctags
  parseTags: (lines) ->
    parse = (line) ->
      line = line.trim()
      if line == ''
        return null

      # Format: tag_name<TAB>file_name<TAB>ex_cmd;"<TAB>extension_fields
      [lpart, rpart] = line.split ';"\t'
      if not lpart? or not rpart?
        console.warn 'ctags-status: Found malformed ctags output - "#{line}"'
        return null

      [tag_name, file_name, pattern...] = lpart.split '\t'
      [tag_type, line_no] = rpart.split '\t'

      line_no = line_no.replace 'line:', ''
      line_no = parseInt line_no, 10
      line_no = line_no - 1  # Use zero based

      (name: tag_name, type: tag_type, start: line_no)

    tags = (parse line for line in lines.split '\n')
    (i for i in tags when i?)

  generateTags: (path, callback) ->
    presets = require.resolve('./.ctagsrc')

    command = atom.config.get('ctags-status.executablePath')

    args = []
    args.push("--options=#{presets}", '--fields=+Kn', '--excmd=p')
    args.push('-R', '-f', '-', path)
    tags = []
    stdout = (lines) =>
      tmp_tags = @parseTags lines
      tags.push tmp_tags...
      tags.sort((x, y) -> x.start - y.start)  # Sort line_no by asc order
    exit = (exitCode) =>
      callback tags

    stderr = (lines) ->
      console.warn lines

    subprocess = new BufferedProcess({command, args, stdout, stderr, exit})
