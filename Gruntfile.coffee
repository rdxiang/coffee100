module.exports = (grunt) ->
  grunt.initConfig #the configuration object
    pkg: grunt.file.readJSON 'package.json' #grab our package.json
    #configure individual packages
    coffeelint:
      app: ['src/*.coffee', 'test/*.coffee']
    coffee:
      compile:
        files: 
          'build/coffee100.js': ['src/coffee100.coffee']  # multiple files will be concat'd
          'build/test/coffee100_spec.js': ['test/coffee100.coffee']
    jasmine:
      E100Tests:
        src: ['build/<%= pkg.name %>.js']  
        options:
          specs: ['build/test/<%= pkg.name %>_spec.js']   
    copy:
      main:
        src: 'src/index.html', dest: 'build/index.html'
    watch:
      files: ['src/*', 'test/*.coffee']
      tasks: ['coffeelint','coffee','jasmine','copy']

  #load our test packages
  grunt.loadNpmTasks 'grunt-contrib-jasmine'
  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  #specify the default tasks
  grunt.registerTask 'default', ['coffeelint', 'coffee','copy', 'jasmine']
