Ctags = null

module.exports =
class TagsGenerator
  constructor: () ->
    Ctags ?= require './backends/ctags'

  destruct: () ->
    Ctags = null
    @ctags = null

  getBackend: (path) ->
    # TODO: Use different backend based on user preferences
    # m = path.match(/(\.[a-zA-Z0-9]+)$/)
    # if m?
    #   fileExt = m[1].toLowerCase()
    # else
    #   fileExt = ''
    #
    # if @multiBackends && backends[fileExt]
    #   backends[fileExt]
    # else
    #   @ctags

    @ctags ?= new Ctags
    @ctags


  generateTags: (path, callback) ->
    backend = @getBackend(path)
    backend.generateTags(path, callback)
