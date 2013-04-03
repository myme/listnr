module.exports = (grunt) ->

  sources = 'src/**/*.coffee'
  examples = 'examples/**/*.coffee'
  tests = 'test/**/*.coffee'

  grunt.initConfig
    buster: {} # Defaults

    coffee:
      dist:
        files:
          'dist/listnr.js': sources
      examples:
        files:
          'dist/listnr-examples.js': examples
      tests:
        files:
          'dist/listnr-test.js': tests

    coffeelint:
      assets: 'Gruntfile.coffee'
      dist: sources
      tests: tests

    connect:
      server: {}

    jshint:
      assets: 'buster.js'

    uglify:
      dist:
        files:
          'dist/listnr.min.js': 'dist/listnr.js'

    watch:
      test:
        files: [
          'Gruntfile.coffee'
          'buster.js'
          sources
          examples
          tests
        ]
        tasks: ['test']

  grunt.loadNpmTasks('grunt-buster')
  grunt.loadNpmTasks('grunt-coffeelint')
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-connect')
  grunt.loadNpmTasks('grunt-contrib-jshint')
  grunt.loadNpmTasks('grunt-contrib-uglify')
  grunt.loadNpmTasks('grunt-contrib-watch')

  grunt.registerTask('lint', ['coffeelint', 'jshint'])
  grunt.registerTask('build', ['lint', 'coffee', 'uglify'])
  grunt.registerTask('start', ['test', 'connect', 'watch'])
  grunt.registerTask('test', ['build', 'buster'])
  grunt.registerTask('default', ['test'])
