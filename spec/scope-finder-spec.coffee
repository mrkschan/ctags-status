ScopeFinder = require '../lib/scope-finder'

describe "ScopeFinder", ->
  it "builds a map of scopes (line => scopes)", ->
    atom.workspace.open('main.txt').then (editor) ->
      finder = ScopeFinder.on(editor)

      input = [{name:'tag', start:1, end:3}]
      output =
        1: ['tag']
        2: ['tag']
        3: ['tag']

      result = finder.scopeMapFrom(input)
      expect(JSON.stringify(result)).toBe JSON.stringify(output)

      input = [{name:'tagA', start:1, end:3}, {name:'tagB', start:0, end:2}]
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

  it "estimates the scope ranges", ->
    waitsForPromise ->
      atom.workspace.open('main.py').then (editor) ->
        finder = ScopeFinder.on(editor)

        input = [
          {"name":"Klass","type":"class","start":0,"indent":0},
          {"name":"func","type":"member","start":3,"indent":1},
          {"name":"Main","type":"class","start":7,"indent":0},
          {"name":"__init__","type":"member","start":8,"indent":1},
          {"name":"func","type":"member","start":11,"indent":1},
          {"name":"decorator","type":"function","start":15,"indent":0},
          {"name":"wrapped","type":"function","start":18,"indent":1},
          {"name":"run","type":"function","start":28,"indent":0}
        ]
        output = [
          {"name":"Klass","type":"class","start":0,"indent":0,"end":6},
          {"name":"func","type":"member","start":3,"indent":1,"end":6},
          {"name":"Main","type":"class","start":7,"indent":0,"end":14},
          {"name":"__init__","type":"member","start":8,"indent":1,"end":10},
          {"name":"func","type":"member","start":11,"indent":1,"end":14},
          {"name":"decorator","type":"function","start":15,"indent":0,"end":27},
          {"name":"wrapped","type":"function","start":18,"indent":1,"end":27},
          {"name":"run","type":"function","start":28,"indent":0,"end":30}
        ]

        result = finder.estimateScopeRanges(input)
        expect(JSON.stringify(result)).toBe JSON.stringify(output)

  it "guesses the end of scopes in .css file", ->
    waitsForPromise ->
      atom.workspace.open('main.css').then (editor) ->
        finder = ScopeFinder.on(editor)
        lastline = editor.getLastBufferRow()
        indentOf = (n) -> editor.indentationForBufferRow n

        input = 0
        output = 2
        result = finder.findScopeEnd(input, lastline, indentOf(input))
        expect(result).toBe output

        input = 4
        output = 6
        result = finder.findScopeEnd(input, lastline, indentOf(input))
        expect(result).toBe output

        input = 8
        output = 10
        result = finder.findScopeEnd(input, lastline, indentOf(input))
        expect(result).toBe output

        input = 12
        output = 14
        result = finder.findScopeEnd(input, lastline, indentOf(input))
        expect(result).toBe output

        input = 16
        output = 16
        result = finder.findScopeEnd(input, lastline, indentOf(input))
        expect(result).toBe output

  it "guesses the end of scopes in .js file", ->
    waitsForPromise ->
      atom.workspace.open('main.js').then (editor) ->
        finder = ScopeFinder.on(editor)
        lastline = editor.getLastBufferRow()
        indentOf = (n) -> editor.indentationForBufferRow n

        input = 0
        output = 2
        result = finder.findScopeEnd(input, lastline, indentOf(input))
        expect(result).toBe output

        input = 4
        output = 7
        result = finder.findScopeEnd(input, lastline, indentOf(input))
        expect(result).toBe output

        input = 9
        output = 11
        result = finder.findScopeEnd(input, lastline, indentOf(input))
        expect(result).toBe output

        input = 13
        output = 16
        result = finder.findScopeEnd(input, lastline, indentOf(input))
        expect(result).toBe output

        input = 19
        output = 21
        result = finder.findScopeEnd(input, lastline, indentOf(input))
        expect(result).toBe output

        input = 22
        output = 25
        result = finder.findScopeEnd(input, lastline, indentOf(input))
        expect(result).toBe output

        input = 29
        output = 31
        result = finder.findScopeEnd(input, lastline, indentOf(input))
        expect(result).toBe output

        input = 32
        output = 35
        result = finder.findScopeEnd(input, lastline, indentOf(input))
        expect(result).toBe output

        input = 38
        output = 38
        result = finder.findScopeEnd(input, lastline, indentOf(input))
        expect(result).toBe output

  it "guesses the end of scopes in .py file", ->
    waitsForPromise ->
      atom.workspace.open('main.py').then (editor) ->
        finder = ScopeFinder.on(editor)
        lastline = editor.getLastBufferRow()
        indentOf = (n) -> editor.indentationForBufferRow n

        input = 0
        output = 4
        result = finder.findScopeEnd(input, lastline, indentOf(input))
        expect(result).toBe output

        input = 3
        output = 4
        result = finder.findScopeEnd(input, lastline, indentOf(input))
        expect(result).toBe output

        input = 15
        output = 22
        result = finder.findScopeEnd(input, lastline, indentOf(input))
        expect(result).toBe output

        input = 18
        output = 20
        result = finder.findScopeEnd(input, lastline, indentOf(input))
        expect(result).toBe output

  it "guesses the end of scopes in .php file", ->
    waitsForPromise ->
      atom.workspace.open('main.php').then (editor) ->
        finder = ScopeFinder.on(editor)
        lastline = editor.getLastBufferRow()
        indentOf = (n) -> editor.indentationForBufferRow n

        input = 2
        output = 4
        result = finder.findScopeEnd(input, lastline, indentOf(input))
        expect(result).toBe output

        input = 6
        output = 13
        result = finder.findScopeEnd(input, lastline, indentOf(input))
        expect(result).toBe output

        input = 9
        output = 12
        result = finder.findScopeEnd(input, lastline, indentOf(input))
        expect(result).toBe output

        input = 15
        output = 15
        result = finder.findScopeEnd(input, lastline, indentOf(input))
        expect(result).toBe output

        input = 17
        output = 18
        result = finder.findScopeEnd(input, lastline, indentOf(input))
        expect(result).toBe output

        input = 20
        output = 27
        result = finder.findScopeEnd(input, lastline, indentOf(input))
        expect(result).toBe output

  it "guesses the end of scopes in .go file", ->
    waitsForPromise ->
      atom.workspace.open('main.go').then (editor) ->
        finder = ScopeFinder.on(editor)
        lastline = editor.getLastBufferRow()
        indentOf = (n) -> editor.indentationForBufferRow n

        input = 2
        output = 4
        result = finder.findScopeEnd(input, lastline, indentOf(input))
        expect(result).toBe output

        input = 6
        output = 6
        result = finder.findScopeEnd(input, lastline, indentOf(input))
        expect(result).toBe output

        input = 8
        output = 10
        result = finder.findScopeEnd(input, lastline, indentOf(input))
        expect(result).toBe output

        input = 12
        output = 14
        result = finder.findScopeEnd(input, lastline, indentOf(input))
        expect(result).toBe output

  it "guesses the end of scopes in .coffee file", ->
    waitsForPromise ->
      atom.workspace.open('main.coffee').then (editor) ->
        finder = ScopeFinder.on(editor)
        lastline = editor.getLastBufferRow()
        indentOf = (n) -> editor.indentationForBufferRow n

        input = 0
        output = 2
        result = finder.findScopeEnd(input, lastline, indentOf(input))
        expect(result).toBe output

        input = 4
        output = 6
        result = finder.findScopeEnd(input, lastline, indentOf(input))
        expect(result).toBe output

        input = 8
        output = 9
        result = finder.findScopeEnd(input, lastline, indentOf(input))
        expect(result).toBe output

        input = 12
        output = 13
        result = finder.findScopeEnd(input, lastline, indentOf(input))
        expect(result).toBe output

        input = 16
        output = 18
        result = finder.findScopeEnd(input, lastline, indentOf(input))
        expect(result).toBe output

        input = 17
        output = 18
        result = finder.findScopeEnd(input, lastline, indentOf(input))
        expect(result).toBe output

        input = 20
        output = 22
        result = finder.findScopeEnd(input, lastline, indentOf(input))
        expect(result).toBe output

        input = 21
        output = 22
        result = finder.findScopeEnd(input, lastline, indentOf(input))
        expect(result).toBe output

  it "guesses the end of scopes in .cpp file", ->
    waitsForPromise ->
      atom.workspace.open('main.cpp').then (editor) ->
        finder = ScopeFinder.on(editor)
        lastline = editor.getLastBufferRow()
        indentOf = (n) -> editor.indentationForBufferRow n

        input = 1
        output = 3
        result = finder.findScopeEnd(input, lastline, indentOf(input))
        expect(result).toBe output

        input = 5
        output = 5
        result = finder.findScopeEnd(input, lastline, indentOf(input))
        expect(result).toBe output

        input = 7
        output = 8
        result = finder.findScopeEnd(input, lastline, indentOf(input))
        expect(result).toBe output

        input = 10
        output = 10
        result = finder.findScopeEnd(input, lastline, indentOf(input))
        expect(result).toBe output

        input = 12
        output = 17
        result = finder.findScopeEnd(input, lastline, indentOf(input))
        expect(result).toBe output

        input = 14
        output = 16
        result = finder.findScopeEnd(input, lastline, indentOf(input))
        expect(result).toBe output

  it "guesses the end of scopes in .java file", ->
    waitsForPromise ->
      atom.workspace.open('main.java').then (editor) ->
        finder = ScopeFinder.on(editor)
        lastline = editor.getLastBufferRow()
        indentOf = (n) -> editor.indentationForBufferRow n

        input = 0
        output = 6
        result = finder.findScopeEnd(input, lastline, indentOf(input))
        expect(result).toBe output

        input = 1
        output = 3
        result = finder.findScopeEnd(input, lastline, indentOf(input))
        expect(result).toBe output

        input = 5
        output = 5
        result = finder.findScopeEnd(input, lastline, indentOf(input))
        expect(result).toBe output

        input = 8
        output = 12
        result = finder.findScopeEnd(input, lastline, indentOf(input))
        expect(result).toBe output

        input = 9
        output = 9
        result = finder.findScopeEnd(input, lastline, indentOf(input))
        expect(result).toBe output

        input = 11
        output = 11
        result = finder.findScopeEnd(input, lastline, indentOf(input))
        expect(result).toBe output

        input = 14
        output = 19
        result = finder.findScopeEnd(input, lastline, indentOf(input))
        expect(result).toBe output

        input = 15
        output = 18
        result = finder.findScopeEnd(input, lastline, indentOf(input))
        expect(result).toBe output

  it "guesses the end of scopes in .rb file", ->
    waitsForPromise ->
      atom.workspace.open('main.rb').then (editor) ->
        finder = ScopeFinder.on(editor)
        lastline = editor.getLastBufferRow()
        indentOf = (n) -> editor.indentationForBufferRow n

        input = 0
        output = 6
        result = finder.findScopeEnd(input, lastline, indentOf(input))
        expect(result).toBe output

        input = 3
        output = 5
        result = finder.findScopeEnd(input, lastline, indentOf(input))
        expect(result).toBe output

        input = 8
        output = 10
        result = finder.findScopeEnd(input, lastline, indentOf(input))
        expect(result).toBe output

        input = 12
        output = 18
        result = finder.findScopeEnd(input, lastline, indentOf(input))
        expect(result).toBe output

        input = 13
        output = 15
        result = finder.findScopeEnd(input, lastline, indentOf(input))
        expect(result).toBe output
