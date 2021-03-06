# Gruntfile.coffee

module.exports = (grunt) ->

  grunt.initConfig
    pkg:    grunt.file.readJSON 'package.json'
    config: grunt.file.readJSON 'config.json'

    dist_path:  'dist'
    build_path: '<%= dist_path %>/build'
    test_path:  '<%= dist_path %>/test'
    src_path:   'src'
    core_path:  'lib/core'

    style_path: '<%= build_path %>/public/stylesheets'

    # helpers
    env: -> ""

    # tasks
    clean:
      dist:  [ '<%= dist_path %>' ]
      tests: [ '<%= test_path %>' ]

    copy:
      src:
        expand: true
        cwd: '<%= src_path %>/'
        src: '**'
        dest: '<%= build_path %>'
        filter: 'isFile'
      core:
        expand: true
        cwd: '<%= core_path %>/app'
        src: [
          '.meteor/**'
          'client/**'
          'server/**'
          'lib/**'
          'packages/**'
        ]
        dest: '<%= build_path %>'
      tests:
        expand: true
        cwd: '<%= core_path %>/test'
        src: '**'
        dest: '<%= test_path %>'
        filter: 'isFile'

    sed:
      game_name:
        path: '<%= build_path %>'
        exclude: '<%= build_path %>/.meteor'
        pattern: '%GAME_NAME%'
        replacement: '<%= config.game_name %>'
        recursive: true
      site_url:
        path: '<%= build_path %>'
        exclude: '<%= build_path %>/.meteor'
        pattern: '%SITE_URL%'
        replacement: '<%= config.site_url %>'
        recursive: true

    watch:
      dist:
        files: ['<%= src_path %>/**']
        tasks: [ 'copy:src', 'less', 'sed', 'coffeelint' ]
      core:
        files: ['<%= core_path %>/app/**']
        tasks: [ 'copy:core', 'sed', 'coffeelint' ]

    coffeelint:
      build:
        files:
          src: '<%= dist_path %>/**/*.coffee'
        options:
          configFile: 'coffeelint.json'

    less:
      main:
        options:
          paths: '<%= style_path %>'
        files:
          '<%= style_path %>/index.css': '<%= style_path %>/index.less'

    bgShell:
      update:
        cmd: 'mrt update'
        bg: false
        options:
          stdout: true
          stderr: true
        execOpts:
          cwd: '<%= build_path %>'
      run:
        cmd: "<%= env() %> meteor"
        bg: true
        options:
          stdout: true
          stderr: true
        execOpts:
          cwd: '<%= build_path %>'

    webdriver:
      tests: ->
        spec = grunt.option 'spec'
        if spec?
          "<%= test_path %>/**/#{spec}_spec.coffee"
        else
          '<%= test_path %>/**/*_spec.coffee'
      options:
        # logLevel: 'verbose'
        timeout: 50000
      chrome:
        tests: [ '<%= webdriver.tests() %>' ]
        options:
          desiredCapabilities: { browserName: 'chrome' }
      phantomjs:
        tests: [ '<%= webdriver.tests() %>' ]
        options:
          desiredCapabilities: { browserName: 'phantomjs' }


  # plugins
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-less'
  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-sed'
  grunt.loadNpmTasks 'grunt-bg-shell'
  grunt.loadNpmTasks 'grunt-webdriver'


  # register
  grunt.registerTask 'lint',    [ 'coffeelint' ]
  grunt.registerTask 'build',   [ 'clean:dist', 'copy:src', 'copy:core', 'sed', 'less', 'lint' ]
  grunt.registerTask 'update',  [ 'bgShell:update' ]
  grunt.registerTask 'run',     [ 'bgShell:run' ]

  browser = grunt.option('browser') || 'chrome'
  grunt.registerTask 'test',    [ 'clean:tests', 'copy:tests', 'webdriver:' + browser ]

  grunt.registerTask 'default', [ 'build', 'update', 'run', 'watch' ]
