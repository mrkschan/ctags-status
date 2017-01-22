TagsGenerator = require '../lib/generator'


describe "TagsGenerator", ->
  it "finds correct backend", ->
    generator = new TagsGenerator

    expect(generator.getBackend('f.js')).toBe generator.ctags
    expect(generator.getBackend('f.coffee')).toBe generator.ctags
    expect(generator.getBackend('f.go')).toBe generator.ctags
    expect(generator.getBackend('f.py')).toBe generator.ctags
