encode = (str) ->
  new Buffer(str, 'ascii').toString('hex')


class Node
  constructor: (key, value) ->
    @key = key
    @value = value

    @next = null
    @last = null


class List
  constructor: ->
    @head = @tail = null
    @length = 0

  attach: (node) ->
    if @head?
      @head.last = node
      node.next = @head
    else
      @tail = node

    @head = node
    @length += 1

  detach: (node) ->
    if node.next?
      node.next.last = node.last
      node.last?.next = node.next
    else
      @tail = node.last

    if node.last?
      node.last.next = node.next
      node.next?.last = node.last
    else
      @head = node.next

    node.next = node.last = null
    @length -= 1

  touch: (node) ->
    if @head == node
      return

    @detach node
    @attach node

  strip: ->
    if not @tail?
      return

    node = @tail
    @detach node

    node

  clear: ->
    node = @head
    while node?
      next = node.next
      node.next = node.last = null
      node = next

    @head = @tail = null
    @length = 0


module.exports =
class LRUCache  # Least-recent-used cache
  constructor: (size) ->
    @size = size

    @index = {}
    @nodes = new List()

  set: (key, value) ->
    encoded_key = encode(key)

    if @index[encoded_key]?
      node = @index[encoded_key]
      node.value = value
    else
      node = new Node(encoded_key, value)
      @nodes.attach(node)
      @index[encoded_key] = node

    if @nodes.length > @size
      least_used = @nodes.strip()
      delete @index[least_used.key]

  get: (key) ->
    node = @index[encode(key)]
    if not node?
      return

    @nodes.touch node
    node.value

  has: (key) ->
    @index[encode(key)]?

  remove: (key) ->
    encoded_key = encode(key)

    if not @index[encode(key)]?
      return

    node = @index[encoded_key]
    @nodes.detach node

    delete @index[encoded_key]

  clear: ->
    @nodes.clear()
    @index = {}
