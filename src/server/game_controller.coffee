# src/server/game_controller.coffee

# methods

Meteor.methods
  newGame: (quiz) ->
    Games.insert
      quizId:            quiz._id
      pointsPerQuestion: CONFIG.POINTS_PER_QUESTION
      state:             'init'
      currentQuestion:   0
      answers:           []

  endGame: (gameId) ->
    game = Games.findOne gameId
    unless game?
      throw new Meteor.Error 404, "Game not found"
    else if game.state is 'finished'
      throw new Meteor.Error 500, "Game already finished"

    # calculate score
    score = 0
    correctAnswers = 0

    for answer in game.answers
      question = Questions.findOne answer.questionId
      sound = Sounds.findOne question.soundId

      if answer.answer is question.correctAnswer
        diff = (answer.endTime - answer.startTime) / 1000

        if diff == 0
          points = CONFIG.POINTS_PER_QUESTION
        else if diff >= sound.duration
          points = 0
        else
          points = (1 - (diff / sound.duration)) * CONFIG.POINTS_PER_QUESTION

        correctAnswers++
        score += points

    # mark game as finished
    Games.update gameId, $set:
      state: 'finished'
      score: parseInt(score)
      correctAnswers: correctAnswers

  startQuestion: (gameId) ->
    game = Games.findOne gameId
    unless game?
      throw new Meteor.Error 404, "Game not found"

    quiz = Quizzes.findOne game.quizId
    unless quiz?
      throw new Meteor.Error 404, "Quiz not found"

    return if game.answers[game.currentQuestion]?

    Games.update gameId,
      $addToSet:
        answers:
          questionId: quiz.questionIds[game.currentQuestion]
          startTime: (new Date()).getTime()

  stopQuestion: (gameId, alternative) ->
    game = Games.findOne gameId
    unless game?
      throw new Meteor.Error 404, "Game not found"

    answer = game.answers[game.currentQuestion]

    answer.endTime = (new Date()).getTime()
    answer.answer = alternative

    Games.update { _id: gameId, 'answers.questionId': answer.questionId } ,
      $set: { 'answers.$': answer }
      $inc: { currentQuestion: 1 }

    return game.currentQuestion + 1
