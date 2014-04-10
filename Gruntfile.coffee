# Gruntfile.coffee

module.exports = (grunt) ->

  # init
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    build_path: 'build'
    src_path:   'src'
    core_path:  'lib/core'

    clean: [ '<%= build_path %>' ]

    copy:
      dist:
        files: [
          # lib/core
          {
            expand: true
            cwd: '<%= core_path %>/app'
            src: [
              '**'
              'packages'
              '.meteor/**'
              '!smart.lock'
              '!packages.json'
            ]
            dest: '<%= build_path %>/dist'
          }
          # src
          {
            expand: true
            cwd: '<%= src_path %>/'
            src: '**'
            dest: '<%= build_path %>/dist'
            filter: 'isFile'
          }
        ]

    shell:
      meteor:
        command: 'mrt'
        options:
          stdout: true
          stderr: true
          execOptions:
            cwd: '<%= build_path %>/dist'


  # plugins
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-shell'


  # tasks
  grunt.registerTask 'build', [ 'clean', 'copy' ]
  grunt.registerTask 'run', [ 'shell:meteor' ]
  grunt.registerTask 'default', [ 'build', 'run' ]
