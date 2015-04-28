module.exports = class Game

  name: 'game'
  view: __dirname
  usersToStart: 2
  maxRounds: 3

  init: ->
    @user = @model.scope '_page.user'
    @game = @model.scope '_page.game'
    @model.ref 'game', @game
    @players = @model.at 'game.players'
    @userIds = @model.at 'game.userIds'
    @model.start 'canJoin', @user, @userIds, @canJoin.bind(@)
    @model.start 'canStart', @game,@userIds, @canStart.bind(@)
    @page.root = @


    @player = @model.ref 'player', @players.at(@user.get('id'))

#    @model.start 'answered', @game, @nextRound.bind(@)


#    @model.set 'answer', null

  create: ->


  nextRound: () ->
    game = @game.get()
    round = game.rounds[game.currentRound]
    for userId in game.userIds
      unless round[userId]?
        return false
    round = @game.increment 'currentRound'
    @player.setEach
      answered: false
      answer: undefined
    if round >= @maxRounds
      @game.set 'finished', true



  join: ->
#    if @canJoin()
    user = @model.root.get @user
    @players.add
      id: user.id
#      hello: 'world'
    @userIds.push user.id

#    @model.set 'canJoin', @canJoin()

  canJoin: (user, userIds)->
    console.log arguments
#    user = @model.root.get @user
#    userIds = @model.root.get @userIds
    if (user.id in userIds)
      return false
    if (userIds.length >= @usersToStart)
      return false


    true

  canStart: (game, userIds)->
#    userIds = @userIds.get()
    console.log arguments
    if game.started
      false
    else if userIds.length >= @usersToStart
      true
    else
      false

  start: ->
    @game.set 'started', true
    @game.set 'currentRound', 1
    @game.set 'finished', false

  answer: ->
    @game.set('rounds.' + @game.get('currentRound') + '.' + @user.get('id'), @model.get('answer'))
    @player.setEach
      answered: true
      answer: @model.get 'answer'
    @nextRound()

    false