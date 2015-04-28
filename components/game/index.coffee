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
    @model.start 'canStart', @game, @userIds, @canStart.bind(@)
    @page.root = @


#    ids = Object.keys('model')
#    @rounds = @model.refList 'rounds', 'game.rounds', 'roundIds'
#    console.log @model.get('rounds')
#    console.log @model.get('roundIds')
    @player = @model.ref 'player', @players.at(@user.get('id'))

    @model.start 'roundIds', @game, @roundIds.bind(@)
    @model.start 'price', @game, @calcPrice.bind(@)
    @model.start 'profit', @game, @calcProfit.bind(@)
    @model.start 'totalProfit', @game, @calcTotalProfit.bind(@)

#    @model.start 'answered', @game, @nextRound.bind(@)


#    @model.set 'answer', null
  create: ->
#    @model.on 'all', 'game.currentRound', @setNotAnswered.bind(@)

#  setNotAnswered: ->
#    @player.setEach
#      answered: false
#      answer: undefined

  calcPrice: (game) ->
    price = {}
    for rkey of game.rounds
      round = game.rounds[rkey]
      i = 0
      for uid of round
        i = i + parseInt(round[uid]);
      pr = 45 - 0.2 * i
      price[rkey] = pr
    price

  calcProfit: (game) ->
    profit = {}
    price = @model.get('price')
    for uid in game.userIds
      profit[uid] = {}
      for rkey of game.rounds
        pr = (price[rkey] - 5) * game.rounds[rkey][uid]
        profit[uid][rkey] = parseInt(pr)
    profit

  calcTotalProfit: (game) ->
    totalProfit = {}
    profit = @model.get('profit')
    for uid in game.userIds
      totalProfit[uid] = 0
      for rkey of game.rounds
        totalProfit[uid] += profit[uid][rkey]
    totalProfit


  roundIds: (game)->
    Object.keys(game.rounds)


  nextRound: () ->
    game = @game.get()
    round = game.rounds[game.currentRound]
    for userId in game.userIds
      unless round[userId]?
        return false
    round = @game.increment 'currentRound'
    for pkey of game.players
      @game.set 'players.' + pkey + '.answered', false
      @game.set 'players.' + pkey + '.answer', undefined
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
    @game.set('rounds.' + @game.get('currentRound') + '.' + @user.get('id'), @model.get('answer'))
    @player.setEach
      answered: true
      answer: @model.get 'answer'
    @nextRound()

    false