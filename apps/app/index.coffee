derby = require 'derby'

app = module.exports = derby.createApp 'app', __filename


#app.module 'user',
#  load: ->
#    @user = @model.at 'users.' +
#        @params.userId || @model.get('_session.userId')
#    @addSubscriptions @user
#    @user.foobar = 'Hello'
#  setup: ->
#    @model.ref '_page.user', @user
#
#
#app.module 'game',
#  load: ->
#    @game = @model.at 'games.' + @params.gameId
#    @addSubscriptions @game
#  setup: ->
#    @model.ref '_page.game', @game
#
#app.module 'player',
#  load: ['user', (user) ->
#    console.log user.foobar
#  ]
#  setup: ->
#    # ...

#app.use require 'derby-router'
app.use require 'derby-debug'
app.serverUse module, 'derby-jade'
app.serverUse module, 'derby-stylus'

app.component  require '../../components/user'
app.component  require '../../components/add-game'
app.component  require '../../components/games-list'
app.component  require '../../components/game'

app.loadViews __dirname + '/views'
app.loadStyles __dirname + '/styles'

global.app = app

#app.get 'home', '/', ['user']
#
#app.get 'game', '/:gameId/:type', ['user', 'game', 'player']

app.proto.f  = (n) ->
  n = parseFloat(n)
  return if isNaN(n)
  n = n.toFixed(2)
  n = ('' + n).replace(/\d(?=(\d{3})+(\.|$))/g, '$&,')
  n = n.replace /\.00$/, ''
  n.replace /\.(.)0$/, '.$1'

app.get '/:foo*', (page, model, params, next) ->
  userId = model.get '_session.userId'
  user = model.at 'users.' + userId

  model.subscribe user, ->
    model.ref '_page.user', user
    unless model.get('_page.user')?
      model.set '_page.user.id', userId
      model.set '_page.user.name', 'NoName'
      model.set '_page.user.prof', false
    next()

app.get '/', (page, model, params) ->
  userId = model.get '_session.userId'
#  console.log 'Home'
  user = model.at 'users.' + userId
  games = model.at 'games'

  model.subscribe user, games, ->
    model.ref '_page.user', user
    model.ref '_page.games', games
    page.render 'home'

app.get '/games/:gameId', (page, model, params) ->
  gameId = params.gameId
  game = model.at 'games.' + gameId

  userId = model.get '_session.userId'
  user = model.at 'users.' + userId
  users = model.at 'users'

  model.subscribe user, game, users,  ->
    if ((model.get game) is undefined)
      page.redirect '/'


    model.ref '_page.game', game
    model.ref '_page.users', users
#    model.ref '_page.user', user
    page.render 'game-page'