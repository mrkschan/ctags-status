function plainJS() {
    return 1;
}

plainJS2 = function() {
    return 1;
}

coffee = ->
    1

object =
    method: ->
        1
    key: 'value'

class T
    constructor: (k) ->
        @k = k

class TT extends T
    f: ->
        1
