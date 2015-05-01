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


    @model.start 'price', @players, @calcPrice.bind(@)
    @model.start 'profit', @players, @calcProfit.bind(@)
    @model.start 'totalProfit', @players, @calcTotalProfit.bind(@)

#    @model.start 'answered', @game, @nextRound.bind(@)


#    @model.set 'answer', null
  create: ->
#    @model.on 'all', 'game.currentRound', @setNotAnswered.bind(@)

#  setNotAnswered: ->
#    @player.setEach
#      answered: false
#      answer: undefined

  calcPrice: (players) ->
    prices = []
    for uid of players
      rounds = players[uid].rounds
      for round, rkey in rounds
        unless prices[rkey]?
          prices[rkey] = 0
        prices[rkey] += parseInt(round)

    for price, pkey in prices
      prices[pkey] = 45 - 0.2 * price

    prices

  calcProfit: (players) ->
    profit = {}
    prices = @model.get('price')

    for uid of players
      player = players[uid]
      profit[uid] = []
      for round, rkey in player.rounds
        pr = (prices[rkey] - 5) * round
        profit[uid][rkey] = parseInt(pr)
    profit

  calcTotalProfit: (players) ->
    totalProfit = {}
    profit = @model.get('profit')
    for uid of players
      player = players[uid]
      totalProfit[uid] = 0
      for round, rkey in player.rounds
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
#    round = game.rounds[game.currentRound - 1]


#    for userId in game.userIds
    for userId of game.players
      user = game.players[userId]
      unless user.rounds[game.currentRound - 1]?
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
      rounds: []
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
#    @game.set(
#      'rounds.' + (@game.get('currentRound') - 1) + '.' + @user.get('id'),
#      @model.get('answer')
#    )
    @player.set(
      'rounds.' + (@game.get('currentRound') - 1),
      @model.get('answer')
    )

    @player.setEach
      answered: true
      answer: @model.get 'answer'
    @model.del 'answer', =>
      @nextRound()