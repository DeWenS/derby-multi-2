module.exports = class GamesList

  name: 'games-list'
  view: __dirname

  init: (model) ->
    @games = model.root.at('_page.games')
    @user = model.root.at('_page.user')
    model.ref 'games', @games.filter()
    model.ref 'user', @user

  delete: (id) ->
    @model.root.del 'games.' + id