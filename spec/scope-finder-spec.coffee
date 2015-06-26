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
        indentOf = (n) -> editor.indentationForBufferRow n

        lastline = editor.getLastBufferRow()
        input = [{start:0},
                 {start:4},
                 {start:8},
                 {start:12},
                 {start:16},
                 ]
        output = [{end:2},
                  {end:6},
                  {end:10},
                  {end:14},
                  {end:16},
                  ]

        for i in input
          do (i) ->
            i.end = lastline
            i.indent = indentOf i.start

        result = finder.makeScopeRanges(input)
        result_ = ({end:i.end} for i in result)
        expect(JSON.stringify(result_)).toBe JSON.stringify(output)

  it "guesses the end of scopes in .js file", ->
    waitsForPromise ->
      atom.workspace.open('main.js').then (editor) ->
        finder = ScopeFinder.on(editor)
        indentOf = (n) -> editor.indentationForBufferRow n

        lastline = editor.getLastBufferRow()
        input = [{start:0},
                 {start:4},
                 {start:9},
                 {start:13},
                 {start:19},
                 {start:22},
                 {start:29},
                 {start:32},
                 {start:38},
                 ]
        output = [{end:2},
                  {end:7},
                  {end:11},
                  {end:16},
                  {end:21},
                  {end:25},
                  {end:31},
                  {end:35},
                  {end:38},
                  ]

        for i in input
          do (i) ->
            i.end = lastline
            i.indent = indentOf i.start

        result = finder.makeScopeRanges(input)
        result_ = ({end:i.end} for i in result)
        expect(JSON.stringify(result_)).toBe JSON.stringify(output)

  it "guesses the end of scopes in .py file", ->
    waitsForPromise ->
      atom.workspace.open('main.py').then (editor) ->
        finder = ScopeFinder.on(editor)
        indentOf = (n) -> editor.indentationForBufferRow n

        lastline = editor.getLastBufferRow()
        input = [{start:0},
                 {start:3},
                 {start:15},
                 {start:18},
                 ]
        output = [{end:4},
                  {end:4},
                  {end:22},
                  {end:20},
                  ]

        for i in input
          do (i) ->
            i.end = lastline
            i.indent = indentOf i.start

        result = finder.makeScopeRanges(input)
        result_ = ({end:i.end} for i in result)
        expect(JSON.stringify(result_)).toBe JSON.stringify(output)

  it "guesses the end of scopes in .php file", ->
    waitsForPromise ->
      atom.workspace.open('main.php').then (editor) ->
        finder = ScopeFinder.on(editor)
        indentOf = (n) -> editor.indentationForBufferRow n

        lastline = editor.getLastBufferRow()
        input = [{start:2},
                 {start:6},
                 {start:9},
                 {start:15},
                 {start:17},
                 {start:20},
                 ]
        output = [{end:4},
                  {end:13},
                  {end:12},
                  {end:15},
                  {end:18},
                  {end:27},
                  ]

        for i in input
          do (i) ->
            i.end = lastline
            i.indent = indentOf i.start

        result = finder.makeScopeRanges(input)
        result_ = ({end:i.end} for i in result)
        expect(JSON.stringify(result_)).toBe JSON.stringify(output)

  it "guesses the end of scopes in .go file", ->
    waitsForPromise ->
      atom.workspace.open('main.go').then (editor) ->
        finder = ScopeFinder.on(editor)
        indentOf = (n) -> editor.indentationForBufferRow n

        lastline = editor.getLastBufferRow()
        input = [{start:2},
                 {start:6},
                 {start:8},
                 {start:12},
                 ]
        output = [{end:4},
                  {end:6},
                  {end:10},
                  {end:14},
                  ]

        for i in input
          do (i) ->
            i.end = lastline
            i.indent = indentOf i.start

        result = finder.makeScopeRanges(input)
        result_ = ({end:i.end} for i in result)
        expect(JSON.stringify(result_)).toBe JSON.stringify(output)

  it "guesses the end of scopes in .coffee file", ->
    waitsForPromise ->
      atom.workspace.open('main.coffee').then (editor) ->
        finder = ScopeFinder.on(editor)
        indentOf = (n) -> editor.indentationForBufferRow n

        lastline = editor.getLastBufferRow()
        input = [{start:0},
                 {start:4},
                 {start:8},
                 {start:12},
                 {start:16},
                 {start:17},
                 {start:20},
                 {start:21},
                 ]
        output = [{end:2},
                  {end:6},
                  {end:9},
                  {end:13},
                  {end:18},
                  {end:18},
                  {end:22},
                  {end:22},
                  ]

        for i in input
          do (i) ->
            i.end = lastline
            i.indent = indentOf i.start

        result = finder.makeScopeRanges(input)
        result_ = ({end:i.end} for i in result)
        expect(JSON.stringify(result_)).toBe JSON.stringify(output)

  it "guesses the end of scopes in .cpp file", ->
    waitsForPromise ->
      atom.workspace.open('main.cpp').then (editor) ->
        finder = ScopeFinder.on(editor)
        indentOf = (n) -> editor.indentationForBufferRow n

        lastline = editor.getLastBufferRow()
        input = [{start:1},
                 {start:5},
                 {start:7},
                 {start:10},
                 {start:12},
                 {start:14},
                 ]
        output = [{end:3},
                  {end:5},
                  {end:8},
                  {end:10},
                  {end:17},
                  {end:16},
                  ]

        for i in input
          do (i) ->
            i.end = lastline
            i.indent = indentOf i.start

        result = finder.makeScopeRanges(input)
        result_ = ({end:i.end} for i in result)
        expect(JSON.stringify(result_)).toBe JSON.stringify(output)

  it "guesses the end of scopes in .java file", ->
    waitsForPromise ->
      atom.workspace.open('main.java').then (editor) ->
        finder = ScopeFinder.on(editor)
        indentOf = (n) -> editor.indentationForBufferRow n

        lastline = editor.getLastBufferRow()
        input = [{start:0},
                 {start:1},
                 {start:5},
                 {start:8},
                 {start:9},
                 {start:11},
                 {start:14},
                 {start:15},
                 ]
        output = [{end:6},
                  {end:3},
                  {end:5},
                  {end:12},
                  {end:9},
                  {end:11},
                  {end:19},
                  {end:18},
                  ]

        for i in input
          do (i) ->
            i.end = lastline
            i.indent = indentOf i.start

        result = finder.makeScopeRanges(input)
        result_ = ({end:i.end} for i in result)
        expect(JSON.stringify(result_)).toBe JSON.stringify(output)

  it "guesses the end of scopes in .rb file", ->
    waitsForPromise ->
      atom.workspace.open('main.rb').then (editor) ->
        finder = ScopeFinder.on(editor)
        indentOf = (n) -> editor.indentationForBufferRow n

        lastline = editor.getLastBufferRow()
        input = [{start:0},
                 {start:3},
                 {start:8},
                 {start:12},
                 {start:13},
                 ]
        output = [{end:6},
                  {end:5},
                  {end:10},
                  {end:18},
                  {end:15},
                  ]

        for i in input
          do (i) ->
            i.end = lastline
            i.indent = indentOf i.start

        result = finder.makeScopeRanges(input)
        result_ = ({end:i.end} for i in result)
        expect(JSON.stringify(result_)).toBe JSON.stringify(output)

  it "guesses the end of scopes in .html file", ->
    waitsForPromise ->
      atom.workspace.open('main.html').then (editor) ->
        finder = ScopeFinder.on(editor)
        indentOf = (n) -> editor.indentationForBufferRow n

        lastline = editor.getLastBufferRow()
        input = [{start:0, end:14},
                 {start:1, end:11},
                 {start:2, end:7},
                 {start:3, end:3},
                 {start:4, end:4},
                 {start:5, end:7},
                 {start:8, end:11},
                 {start:12, end:14},
                 ]
        output = [{end:13},
                  {end:9},
                  {end:6},
                  {end:3},
                  {end:4},
                  {end:6},
                  {end:9},
                  {end:13},
                  ]

        for i in input
          do (i) ->
            i.indent = indentOf i.start

        result = finder.makeScopeRanges(input)
        result_ = ({end:i.end} for i in result)
        expect(JSON.stringify(result_)).toBe JSON.stringify(output)

  it "guesses the end of scopes in .less file", ->
    waitsForPromise ->
      atom.workspace.open('main.less').then (editor) ->
        finder = ScopeFinder.on(editor)
        indentOf = (n) -> editor.indentationForBufferRow n

        lastline = editor.getLastBufferRow()
        input = [{start:0},
                 {start:3},
                 {start:5},
                 {start:8},
                 {start:14},
                 {start:16},
                 ]
        output = [{end:12},
                  {end:3},
                  {end:11},
                  {end:10},
                  {end:14},
                  {end:18},
                  ]

        for i in input
          do (i) ->
            i.end = lastline
            i.indent = indentOf i.start

        result = finder.makeScopeRanges(input)
        result_ = ({end:i.end} for i in result)
        expect(JSON.stringify(result_)).toBe JSON.stringify(output)

  it "guesses the end of scopes in .scss file", ->
    waitsForPromise ->
      atom.workspace.open('main.scss').then (editor) ->
        finder = ScopeFinder.on(editor)
        indentOf = (n) -> editor.indentationForBufferRow n

        lastline = editor.getLastBufferRow()
        input = [{start:3},
                 {start:8},
                 {start:9},
                 {start:15},
                 {start:17},
                 {start:24},
                 {start:31},
                 ]
        output = [{end:6},
                  {end:22},
                  {end:13},
                  {end:15},
                  {end:21},
                  {end:29},
                  {end:31},
                  ]

        for i in input
          do (i) ->
            i.end = lastline
            i.indent = indentOf i.start

        result = finder.makeScopeRanges(input)
        result_ = ({end:i.end} for i in result)
        expect(JSON.stringify(result_)).toBe JSON.stringify(output)

  it "guesses the end of scopes in .sass file", ->
    waitsForPromise ->
      atom.workspace.open('main.sass').then (editor) ->
        finder = ScopeFinder.on(editor)
        indentOf = (n) -> editor.indentationForBufferRow n

        lastline = editor.getLastBufferRow()
        input = [{start:3},
                 {start:7},
                 {start:8},
                 {start:13},
                 {start:16},
                 {start:21},
                 {start:27},
                 ]
        output = [{end:5},
                  {end:19},
                  {end:11},
                  {end:14},
                  {end:19},
                  {end:25},
                  {end:28},
                  ]

        for i in input
          do (i) ->
            i.end = lastline
            i.indent = indentOf i.start

        result = finder.makeScopeRanges(input)
        result_ = ({end:i.end} for i in result)
        expect(JSON.stringify(result_)).toBe JSON.stringify(output)

  it "guesses the end of scopes in .pl file", ->
    waitsForPromise ->
      atom.workspace.open('main.pl').then (editor) ->
        finder = ScopeFinder.on(editor)
        indentOf = (n) -> editor.indentationForBufferRow n

        lastline = editor.getLastBufferRow()
        input = [{start:2},
                 {start:6},
                 ]
        output = [{end:4},
                  {end:8},
                  ]

        for i in input
          do (i) ->
            i.end = lastline
            i.indent = indentOf i.start

        result = finder.makeScopeRanges(input)
        result_ = ({end:i.end} for i in result)
        expect(JSON.stringify(result_)).toBe JSON.stringify(output)
