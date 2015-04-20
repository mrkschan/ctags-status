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

  it "guesses the end of scopes in .css file", ->
    waitsForPromise ->
      atom.workspace.open('main.css').then (editor)->
        input = 0
        output = 2
        result = ScopeFinder.guessedTagEnd(input)
        expect(result).toBe output

        input = 4
        output = 6
        result = ScopeFinder.guessedTagEnd(input)
        expect(result).toBe output

        input = 8
        output = 10
        result = ScopeFinder.guessedTagEnd(input)
        expect(result).toBe output

        input = 12
        output = 14
        result = ScopeFinder.guessedTagEnd(input)
        expect(result).toBe output

  it "guesses the end of scopes in .py file", ->
    waitsForPromise ->
      atom.workspace.open('main.py').then (editor)->
        input = 0
        output = 6
        result = ScopeFinder.guessedTagEnd(input)
        expect(result).toBe output

        input = 3
        output = 6
        result = ScopeFinder.guessedTagEnd(input)
        expect(result).toBe output

        input = 15
        output = 23
        result = ScopeFinder.guessedTagEnd(input)
        expect(result).toBe output

        input = 18
        output = 21
        result = ScopeFinder.guessedTagEnd(input)
        expect(result).toBe output
