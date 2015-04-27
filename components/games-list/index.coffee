module.exports = class GamesList

  name: 'games-list'
  view: __dirname

  init: (model) ->
    @games = model.root.at('_page.games')
    model.ref 'games', @games.filter()

  delete: (id) ->
    @model.root.del 'games.' + id