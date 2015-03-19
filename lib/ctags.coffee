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

            [tag, type, lineno]

        tags = (parse line for line in lines.split '\n')
        (tag for tag in tags when tag.length > 0)

    getTags: (path, success_cb, error_cb) ->
        presets = require.resolve('./.ctagsrc')

        command = 'ctags'

        args = []
        args.push("--options=#{presets}", '--fields=+KSn', '--excmd=p')
        args.push('-R', '-f', '-', path)

        stdout = (lines) =>
            tags = this.parseTags lines
            success_cb tags

        stderr = (lines) =>
            error_cb lines

        subprocess = new BufferedProcess({command, args, stdout, stderr})
