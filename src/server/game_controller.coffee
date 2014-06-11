# src/server/game_controller.coffee

# methods

Meteor.methods
  newGame: ->
    # Find the quiz of the day
    now = new Date()
    quizOfTheDay = Quizzes.find(
      startDate: { $lt: now }
      endDate:   { $gt: now }
    ,
      limit: 1
      sort: ['endDate', 'desc'] # Grab the quiz that ends the soonest
    ).fetch()[0]

    unless quizOfTheDay?
      throw new Meteor.Error 404, "Quiz of the day not found"

    Games.insert
      quizId:            quizOfTheDay._id
      pointsPerQuestion: CONFIG.POINTS_PER_QUESTION
      state:             'init'
      currentQuestion:   0
      answers:           []

  endGame: (gameId) ->
    game = Games.findOne gameId
    throw new Meteor.Error 404, "Game not found" unless game?

    # calculate score
    score = 0
    correctAnswers = 0
    for a in game.answers
      q = Questions.findOne a.questionId
      if a.answer is q.correctAnswer
        correctAnswers++
        score += a.points

    # mark game as finished
    Games.update gameId, $set:
      state: 'finished'
      score: score
      correctAnswers: correctAnswers
