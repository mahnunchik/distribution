Assets = require('../').Distribution
cssProcessor = require('../').cssProcessor
assert = require 'assert'
fs = require 'fs'
rimraf = require 'rimraf'

logger = {}

describe 'Distribution', ()->
  
  beforeEach (done)->
    rimraf 'assets', (err)->
      return done(err) if err?
      rimraf 'public', (err)->
        done(err)
  

  describe '#make()', ()->

    it 'single asset without options', ()->
      a = new Assets({logger: logger})
      file = 'test/fixtures/test.js'
      a.make(file)
      assert.equal a.get(file), '/test-454d740c0200f454a7e81b3cb06c945f.js'
      assert.equal fs.existsSync('assets/test-454d740c0200f454a7e81b3cb06c945f.js'), true

    it 'single asset with global options', ()->
      a = new Assets
        logger: logger
        assetDir: 'public'
        rootUrl: '/abc/'
      file = 'test/fixtures/test.js'
      a.make(file)
      assert.equal a.get(file), '/abc/test-454d740c0200f454a7e81b3cb06c945f.js'
      assert.equal fs.existsSync('public/test-454d740c0200f454a7e81b3cb06c945f.js'), true

    it 'multiple assets', ()->
      a = new Assets
        logger: logger
        assetDir: 'public'
        rootUrl: '/abc/'
      js = 'test/fixtures/test.js'
      css = 'test/fixtures/test.css'
      a.make
        js:
          file: js
        css:
          file: css
          hash: false
      assert.equal a.get('js'), '/abc/test-454d740c0200f454a7e81b3cb06c945f.js'
      assert.equal a.get('css'), '/abc/test.css'
      assert.equal fs.existsSync('public/test-454d740c0200f454a7e81b3cb06c945f.js'), true
      assert.equal fs.existsSync('public/test.css'), true

    it 'wrong key', ()->
      a = new Assets({logger: logger})
      assert.equal a.get('asdfgh'), undefined
      assert.equal a.get('qwertyu'), undefined

    it 'should asset images and replase url', ()->
      a = new Assets
        logger: logger
        processors: 
          'text/css': cssProcessor
      file = 'test/fixtures/bootstrap/css/bootstrap.css'
      a.make(file)
      assert.equal a.get(file), '/bootstrap-a99472f4c79ed11daa3340210c9c206b.css'
      assert.equal a.get('../fonts/glyphiconshalflings-regular.svg'), '/glyphiconshalflings-regular-d482b7e5283a44780b9c47f3276314e9.svg'
      assert.equal a.get('../fonts/glyphiconshalflings-regular.ttf'), '/glyphiconshalflings-regular-fc7ebef874e3a3786aa60d9bc4a75519.ttf'
      assert.equal a.get('../fonts/glyphiconshalflings-regular.woff'), '/glyphiconshalflings-regular-b177def5c9d78ab14562ca652b7bed48.woff'
      assert.equal a.get('../fonts/glyphiconshalflings-regular.eot'), '/glyphiconshalflings-regular-5ed8ce6d7757638311ffdaa820021aae.eot'

    it 'should asset images and replase url (min css)', ()->
      a = new Assets
        logger: logger
        processors: 
          'text/css': cssProcessor
      file = 'test/fixtures/bootstrap/css/bootstrap.min.css'
      a.make(file)
      assert.equal a.get(file), '/bootstrap.min-52a6003f439d25a1e5612c92166e94f9.css'
      assert.equal a.get('../fonts/glyphiconshalflings-regular.svg'), '/glyphiconshalflings-regular-d482b7e5283a44780b9c47f3276314e9.svg'
      assert.equal a.get('../fonts/glyphiconshalflings-regular.ttf'), '/glyphiconshalflings-regular-fc7ebef874e3a3786aa60d9bc4a75519.ttf'
      assert.equal a.get('../fonts/glyphiconshalflings-regular.woff'), '/glyphiconshalflings-regular-b177def5c9d78ab14562ca652b7bed48.woff'
      assert.equal a.get('../fonts/glyphiconshalflings-regular.eot'), '/glyphiconshalflings-regular-5ed8ce6d7757638311ffdaa820021aae.eot'

    it.only 'should asset directory', ()->
      a = new Assets
        logger: logger
      a.make("test/fixtures/**/*.png")
      console.log a
      assert.notEqual a.get 'test/fixtures/bootstrap/img_old/glyphicons-halflings-white.png', null
      assert.notEqual a.get 'test/fixtures/bootstrap/img_old/glyphicons-halflings.png', null
      assert.notEqual a.get 'test/fixtures/glyphicons-halflings-white.png', null

