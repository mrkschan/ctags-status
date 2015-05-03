LRUCache = require '../lib/cache'


describe "LRUCache", ->
  it "builds a cache of key => value", ->
      cache = new LRUCache(5)

      cache.set('k1', 'v1')
      cache.set('k2', 'v2')
      cache.set('k3', 'v3')

      expect(cache.get('k1')).toBe 'v1'
      expect(cache.get('k2')).toBe 'v2'
      expect(cache.get('k3')).toBe 'v3'
      expect(cache.get('k4')).toBe undefined

  it "removes the least recent used items", ->
      cache = new LRUCache(4)

      cache.set('k1', 'v1')
      cache.set('k2', 'v2')
      cache.set('k3', 'v3')
      cache.set('k4', 'v4')
      cache.set('k5', 'v5')
      cache.set('k6', 'v6')

      expect(cache.get('k1')).toBe undefined
      expect(cache.get('k2')).toBe undefined
      expect(cache.get('k3')).toBe 'v3'
      expect(cache.get('k4')).toBe 'v4'
      expect(cache.get('k5')).toBe 'v5'
      expect(cache.get('k6')).toBe 'v6'

  it "keeps the most recent item at the front of the list", ->
      cache = new LRUCache(4)

      cache.set('k1', 'v1')
      cache.set('k2', 'v2')
      cache.set('k3', 'v3')
      cache.set('k4', 'v4')

      cache.get('k1')
      cache.get('k3')

      node = cache.nodes.head
      expect(node.value).toBe 'v3'

      node = node.next
      expect(node.value).toBe 'v1'

      node = node.next
      expect(node.value).toBe 'v4'

      node = node.next
      expect(node.value).toBe 'v2'

    it "supports item removal", ->
      cache = new LRUCache(4)

      cache.set('k1', 'v1')
      cache.set('k2', 'v2')
      cache.set('k3', 'v3')
      cache.set('k4', 'v4')

      cache.remove('k3')

      expect(cache.get('k1')).toBe 'v1'
      expect(cache.get('k2')).toBe 'v2'
      expect(cache.get('k3')).toBe undefined
      expect(cache.get('k4')).toBe 'v4'

      cache.clear()

      expect(cache.get('k1')).toBe undefined
      expect(cache.get('k2')).toBe undefined
      expect(cache.get('k3')).toBe undefined
      expect(cache.get('k4')).toBe undefined
