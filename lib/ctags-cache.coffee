encode = (str) ->
  new Buffer(str, 'ascii').toString('hex')

# TODO: Adopt Least-recently-used Cache
cache = {}

module.exports = {
  add: (key, value) ->
    cache[encode(key)] = value

  get: (key) ->
    cache[encode(key)]

  has: (key) ->
    cache[encode(key)]?

  remove: (key) ->
    delete cache[encode(key)]
}
