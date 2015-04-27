module.exports = class Game

  name: 'game'
  view: __dirname

  init: ->
    @game = @model.root.at('_page.game')
    @model.ref 'game', @game

  join: ->
    user = @model.root.get '_page.user'
    console.log user