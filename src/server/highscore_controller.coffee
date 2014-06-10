# src/server/highscore_controller.coffee

# methods

Meteor.methods
  submitHighscore: (name, gameId) ->
    console.log 'submitting highscore'

    unless name
      throw new Meteor.Error "Name empty"
    unless Games.find( _id: gameId ).count() == 1
      throw new Meteor.Error "Game not found"

    Highscores.insert
      name: name
      gameId: gameId
