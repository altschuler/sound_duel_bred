# src/server/highscore_controller.coffee

# methods

Meteor.methods
  submitHighscore: (name, gameId) ->
    unless name
      throw new Meteor.Error 403, "Name empty"

    game = Games.findOne gameId
    unless game?
      throw new Meteor.Error 404, "Game not found"

    Highscores.insert
      name: name
      gameId: gameId
      quizId: game.quizId
      score: game.score
