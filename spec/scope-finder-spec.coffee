ScopeFinder = require '../lib/scope-finder'

describe "ScopeFinder", ->
  it "builds a map of scopes (line => scopes)", ->
    finder = ScopeFinder.on(null)

    input = [['tag', 1, 3]]
    output =
      1: ['tag']
      2: ['tag']
      3: ['tag']

    result = finder.scopeMapFrom(input)
    expect(JSON.stringify(result)).toBe JSON.stringify(output)

    input = [['tagA', 1, 3], ['tagB', 0, 2]]
    output =
      0: ['tagB']
      1: ['tagA', 'tagB']
      2: ['tagA', 'tagB']
      3: ['tagA']

    result = finder.scopeMapFrom(input)
    expect(JSON.stringify(result)).toBe JSON.stringify(output)

    input = []
    output = {}

    result = finder.scopeMapFrom(input)
    expect(JSON.stringify(result)).toBe JSON.stringify(output)

  it "guesses the end of scopes in .css file", ->
    waitsForPromise ->
      atom.workspace.open('main.css').then (editor) ->
        finder = ScopeFinder.on(editor)

        input = 0
        output = 2
        result = finder.guessedTagEndFrom(input)
        expect(result).toBe output

        input = 4
        output = 6
        result = finder.guessedTagEndFrom(input)
        expect(result).toBe output

        input = 8
        output = 10
        result = finder.guessedTagEndFrom(input)
        expect(result).toBe output

        input = 12
        output = 14
        result = finder.guessedTagEndFrom(input)
        expect(result).toBe output

        input = 16
        output = 16
        result = finder.guessedTagEndFrom(input)
        expect(result).toBe output

  it "guesses the end of scopes in .js file", ->
    waitsForPromise ->
      atom.workspace.open('main.js').then (editor) ->
        finder = ScopeFinder.on(editor)

        input = 0
        output = 2
        result = finder.guessedTagEndFrom(input)
        expect(result).toBe output

        input = 4
        output = 7
        result = finder.guessedTagEndFrom(input)
        expect(result).toBe output

        input = 9
        output = 11
        result = finder.guessedTagEndFrom(input)
        expect(result).toBe output

        input = 13
        output = 16
        result = finder.guessedTagEndFrom(input)
        expect(result).toBe output

        input = 19
        output = 21
        result = finder.guessedTagEndFrom(input)
        expect(result).toBe output

        input = 22
        output = 25
        result = finder.guessedTagEndFrom(input)
        expect(result).toBe output

        input = 29
        output = 31
        result = finder.guessedTagEndFrom(input)
        expect(result).toBe output

        input = 32
        output = 35
        result = finder.guessedTagEndFrom(input)
        expect(result).toBe output

        input = 38
        output = 38
        result = finder.guessedTagEndFrom(input)
        expect(result).toBe output

  it "guesses the end of scopes in .py file", ->
    waitsForPromise ->
      atom.workspace.open('main.py').then (editor) ->
        finder = ScopeFinder.on(editor)

        input = 0
        output = 4
        result = finder.guessedTagEndFrom(input)
        expect(result).toBe output

        input = 3
        output = 4
        result = finder.guessedTagEndFrom(input)
        expect(result).toBe output

        input = 15
        output = 22
        result = finder.guessedTagEndFrom(input)
        expect(result).toBe output

        input = 18
        output = 20
        result = finder.guessedTagEndFrom(input)
        expect(result).toBe output

  it "guesses the end of scopes in .php file", ->
    waitsForPromise ->
      atom.workspace.open('main.php').then (editor) ->
        finder = ScopeFinder.on(editor)

        input = 2
        output = 4
        result = finder.guessedTagEndFrom(input)
        expect(result).toBe output

        input = 6
        output = 13
        result = finder.guessedTagEndFrom(input)
        expect(result).toBe output

        input = 9
        output = 12
        result = finder.guessedTagEndFrom(input)
        expect(result).toBe output

        input = 15
        output = 15
        result = finder.guessedTagEndFrom(input)
        expect(result).toBe output

        input = 17
        output = 18
        result = finder.guessedTagEndFrom(input)
        expect(result).toBe output

        input = 20
        output = 27
        result = finder.guessedTagEndFrom(input)
        expect(result).toBe output

  it "guesses the end of scopes in .go file", ->
    waitsForPromise ->
      atom.workspace.open('main.go').then (editor) ->
        finder = ScopeFinder.on(editor)

        input = 2
        output = 4
        result = finder.guessedTagEndFrom(input)
        expect(result).toBe output

        input = 6
        output = 6
        result = finder.guessedTagEndFrom(input)
        expect(result).toBe output

        input = 8
        output = 10
        result = finder.guessedTagEndFrom(input)
        expect(result).toBe output

        input = 12
        output = 14
        result = finder.guessedTagEndFrom(input)
        expect(result).toBe output
