constants = require '../../apps/app/constants'

module.exports = class Game

  name: 'game'
  view: __dirname
  usersToStart: constants.test
  maxRounds: 3

  init: ->
    @user = @model.scope '_page.user'
    @game = @model.scope '_page.game'
    @model.ref 'game', @game
    @players = @model.at 'game.players'
    @userIds = @model.at 'game.userIds'
    @rounds = @game.at 'rounds'
    @model.start 'canJoin', @user, @userIds, @canJoin.bind(@)
    @model.start 'canStart', @game, @userIds, @canStart.bind(@)
    @page.root = @


#    ids = Object.keys('model')
#    @rounds = @model.refList 'rounds', 'game.rounds', 'roundIds'
#    console.log @model.get('rounds')
#    console.log @model.get('roundIds')
    @player = @model.ref 'player', @players.at(@user.get('id'))

    @model.start 'roundIds', @rounds, @roundIds.bind(@)
    @model.start 'price', @rounds, @calcPrice.bind(@)
    @model.start 'profit', @rounds, @calcProfit.bind(@)
    @model.start 'totalProfit', @rounds, @calcTotalProfit.bind(@)

#    @model.start 'answered', @game, @nextRound.bind(@)


#    @model.set 'answer', null
  create: ->
#    @model.on 'all', 'game.currentRound', @setNotAnswered.bind(@)

#  setNotAnswered: ->
#    @player.setEach
#      answered: false
#      answer: undefined

  calcPrice: (rounds) ->
    price = []
    for round, rkey in rounds
      console.log rkey
      i = 0
      for uid of round
        i = i + parseInt(round[uid]);
      pr = 45 - 0.2 * i
      price[rkey] = pr
    price

  calcProfit: (rounds) ->
    profit = {}
    price = @model.get('price')
    for uid in @game.get('userIds')
      profit[uid] = []
      for round, rkey in rounds
        pr = (price[rkey] - 5) * round[uid]
        profit[uid][rkey] = parseInt(pr)
    profit

  calcTotalProfit: (rounds) ->
    totalProfit = {}
    profit = @model.get('profit')
    for uid in @game.get('userIds')
      totalProfit[uid] = 0
      for round, rkey in rounds
        totalProfit[uid] += profit[uid][rkey]
    totalProfit


  roundIds: (rounds)->
    Object.keys(rounds)

  isWatcher: ->
    @user.prof?

  showData: (user, game, roundId) ->
    if ((user.prof) || game.currentRound >= roundId + 1)
      true
    false

  nextRound: () ->
    game = @game.get()
    round = game.rounds[game.currentRound - 1]
    for userId in game.userIds
      unless round[userId]?
        return false
    round = @game.increment 'currentRound'
    for pkey of game.players
      @game.set 'players.' + pkey + '.answered', false
      @game.del 'players.' + pkey + '.answer'
    if round > @maxRounds
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
#    user = @model.root.get @user
#    userIds = @model.root.get @userIds
    if (user.id in userIds)
      return false
    if (userIds.length >= @usersToStart)
      return false
    if (user.prof)
      return false


    true

  canStart: (game, userIds)->
#    userIds = @userIds.get()
#    console.log arguments
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
    @game.set(
      'rounds.' + (@game.get('currentRound') - 1) + '.' + @user.get('id'),
      @model.get('answer')
    )
    @player.setEach
      answered: true
      answer: @model.get 'answer'
    @model.del 'answer', =>
      @nextRound()