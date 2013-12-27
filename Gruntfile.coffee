'use strict'

module.exports = (grunt) ->

  require 'coffee-errors'

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-simple-mocha'
  grunt.loadNpmTasks 'grunt-notify'

  grunt.registerTask 'test',    [ 'coffeelint', 'coffee', 'simplemocha' ]
  grunt.registerTask 'default', [ 'test', 'watch' ]

  grunt.initConfig

    coffeelint:
      options:
        max_line_length:
          value: 79
        indentation:
          value: 2
        newlines_after_classes:
          level: 'error'
        no_empty_param_list:
          level: 'error'
        no_unnecessary_fat_arrows:
          level: 'ignore'
      dist:
        files: [
          { expand: yes, cwd: 'src/', src: [ '**/*.coffee' ] }
          { expand: yes, cwd: 'tests/', src: [ '**/*.coffee' ] }
          { expand: yes, cwd: 'sample/coffee/', src: [ '**/*.coffee' ] }
        ]

    coffee:
      dist:
        files: [{
          expand: yes
          cwd: 'src/'
          src: [ '**/*.coffee' ]
          dest: 'lib/'
          ext: '.js'
        }
        {
          expand: yes
          cwd: 'sample/coffee/'
          src: [ '**/*.coffee' ]
          dest: 'sample/js/'
          ext: '.js'
        }]

    simplemocha:
      options:
        ui: 'bdd'
        reporter: 'spec'
        compilers: 'coffee:coffee-script'
        ignoreLeaks: no
      dist:
        src: [ 'tests/*.coffee' ]

    watch:
      options:
        interrupt: yes
      dist:
        files: [ 'src/**/*.coffee', 'tests/**/*.coffee', 'sample/**/*.coffee' ]
        tasks: [ 'test' ]
