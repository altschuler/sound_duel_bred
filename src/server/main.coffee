# src/server/main.coffee

fs = Npm.require 'fs'
Future = Npm.require 'fibers/future'
probe = Meteor.require 'node-ffprobe'

# methods

refreshDb = ->
  # clear database
  # TODO: only for development
  Games.remove({})
  Highscores.remove({})
  Quizzes.remove({})
  Questions.remove({})
  Sounds.remove({})

  # get audiofiles from /public
  audioFiles = fs.readdirSync(CONFIG.ASSETS_DIR).filter (file) ->
    ~file.indexOf('.mp3')

  # parse questions from sample file
  quizzes = EJSON.parse(Assets.getText CONFIG.DATA_PATH)

  # populate database
  for quiz in quizzes

    if true # Quizzes.find( name: quiz.name ).count() == 0
      console.log "New quiz: #{quiz.name}"

      # Insert questions from quiz as separate question objects in database
      questionIds = []

      for question in quiz.questions

        # find associated segment
        segment = audioFiles.filter( (file) ->
          ~file.indexOf(question.soundfilePrefix)
        ).pop()

        # get duration of segment
        fut = new Future()
        probe "#{CONFIG.ASSETS_DIR}/#{segment}", (err, data) ->
          if err?
            console.log err
          else
            fut['return'] data.format.duration

        duration = fut.wait()

        # insert sound document
        soundId = Sounds.insert
          segment: segment
          duration: duration
        question.soundId = soundId

        # insert question into databse
        questionId = Questions.insert question
        questionIds.push questionId

      # Replace the 'questions' property with the property 'questionIds' that
      # references the questions ID in the MongoDB
      delete quiz.questions
      quiz.questionIds = questionIds
      quiz.pointsPerQuestion = CONFIG.POINTS_PER_QUESTION

      Quizzes.insert quiz




# initialize

Meteor.startup ->
  console.log "Starting up..."

  console.log "Meteor.settings:"
  console.log Meteor.settings

  console.log "Refreshing db..."
  refreshDb()

  console.log "Num of quizzes: #{Quizzes.find().count()}"
