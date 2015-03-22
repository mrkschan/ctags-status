{BufferedProcess} = require 'atom'
Q = require 'q'

module.exports =
class Ctags
    constructor: ->
        # TODO: Adopt Least-recently-used Cache
        @cache = {}

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

    generateTags: (path) ->
        presets = require.resolve('./.ctagsrc')

        command = 'ctags'

        args = []
        args.push("--options=#{presets}", '--fields=+KSn', '--excmd=p')
        args.push('-R', '-f', '-', path)

        stdout = (lines) =>
            tags = this.parseTags lines
            tags.sort((x, y) -> y[2] - x[2])  # Sort lineno by desc order

            @cache[path] = tags
            @deferred.resolve()

        stderr = (lines) =>
            console.warn lines
            @deferred.reject()

        subprocess = new BufferedProcess({command, args, stdout, stderr})

    getTags: (path, consumer, force=false) ->
        @deferred = Q.defer([path])

        @deferred.promise.then =>
            tags = @cache[path]
            consumer tags

        if force or not @cache[path]?
            @generateTags path
        else
            @deferred.resolve()
