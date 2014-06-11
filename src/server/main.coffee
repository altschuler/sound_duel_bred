# src/server/main.coffee

fs = Npm.require 'fs'

# methods

refreshDb = ->
  console.log "Refreshing db.."

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

    # Insert questions from quiz as separate question objects in database
    questionIds = []

    for question in quiz.questions

      # find associated segments
      segments = audioFiles.filter (file) ->
        ~file.indexOf(question.soundfilePrefix)

      soundId = Sounds.insert segments: segments
      question.soundId = soundId

      # insert question into databse
      questionId = Questions.insert question
      questionIds.push questionId

    # Replace the 'questions' property with the property 'questionIds' that
    # references the questions ID in the MongoDB
    delete quiz.questions
    quiz.questionIds = questionIds
    quiz.pointsPerQuestion = CONFIG.POINTS_PER_QUESTION

    Quizzes.insert(quiz)


  # print some info
  console.log "#Questions: #{Questions.find().count()}"
  console.log "#Sounds: #{Sounds.find().count()}"


# initialize

Meteor.startup ->
  refreshDb()
