Q = require 'q'

module.exports = (howlong) ->
  callback = @async()

  deferred = Q.defer()

  done = ->
    emit('finish', {})
    callback()

  deferred.promise.then done

  Q.delay(howlong).then ->
    deferred.resolve()
