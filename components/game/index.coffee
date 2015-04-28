module.exports = class Game

  name: 'game'
  view: __dirname
  usersToStart: 2

  init: ->
    @user = @model.root.at '_page.user'
    @game = @model.root.at '_page.game'
    @model.ref 'game', @game
    @players = @model.at 'game.players'
    @userIds = @model.at 'game.userIds'
    @model.set 'canJoin', @canJoin()
    @model.set 'canStart', @canStart()

  join: ->
    if @canJoin()
      user = @model.root.get @user
      @model.add @players, {'id': user.id}
      @model.push @userIds, user.id

      @model.set 'canJoin', @canJoin()

  canJoin: ->
    user = @model.root.get @user
    userIds = @model.root.get @userIds
    if (user.id in userIds)
      return false
    if (userIds.length >= @usersToStart)
      return false


    true

  canStart: ->
    userIds = @model.get @userIds
    if (@game.get 'started')
      return false

    if (userIds.length >= @usersToStart)
      return true


    false

  start: ->
    @game.set 'started', true
    @game.set 'currentRound', 1
    @game.set 'finished', false