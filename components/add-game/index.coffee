module.exports = class AddGame

  name: 'add-game'
  view: __dirname

  init: ->
    @games = @model.root.at('_page.games')
#    @model.ref 'games', @games
    @model.set 'game_name', null

  add: ->
    name = @model.get 'game_name'
    if name == null
      alert 'Please, enter name'
    else
      @model.add @games, {
        name: name,
        players: {},
        userIds: [],
        rounds: {},
        ready: false,
        started: false,
        finished: false,
        currentRound: 1
      }
      @model.set 'game_name', null