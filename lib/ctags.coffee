{BufferedProcess} = require 'atom'


module.exports =
class Ctags
    generateTagFile: (@path) ->
        presets = require.resolve('./.ctagsrc')

        command = 'ctags'

        args = []
        args.push("--options=#{presets}", '--fields=+KSn', '--excmd=p')
        args.push('-R', '-f', '-', @path)

        stdout = (lines) ->
            console.log lines

        stderr = (lines) ->
            console.log lines

        exit = (code) ->
            console.log code

        subprocess = new BufferedProcess({command, args, stdout, stderr, exit})
