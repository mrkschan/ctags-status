ScopeFinder = require '../lib/scope-finder'

describe "ScopeFinder", ->
  it "builds a map of scopes (line => scopes)", ->
    input = [['tag', 1, 3]]
    output =
      1: ['tag']
      2: ['tag']
      3: ['tag']

    result = ScopeFinder.buildScopeMap(input)
    expect(JSON.stringify(result)).toBe JSON.stringify(output)

    input = [['tagA', 1, 3], ['tagB', 0, 2]]
    output =
      0: ['tagB']
      1: ['tagA', 'tagB']
      2: ['tagA', 'tagB']
      3: ['tagA']

    result = ScopeFinder.buildScopeMap(input)
    expect(JSON.stringify(result)).toBe JSON.stringify(output)

    input = []
    output = {}

    result = ScopeFinder.buildScopeMap(input)
    expect(JSON.stringify(result)).toBe JSON.stringify(output)
