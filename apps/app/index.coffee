derby = require 'derby'

app = module.exports = derby.createApp 'app', __filename


app.use require 'derby-router'
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

app.get '**', (page, model, params, next) ->
  user = model.at 'users.' + userId
  model.subscribe user, ->
    model.ref '_page.user', user
    next();

app.get '/', (page, model, params) ->
  userId = model.get '_session.userId'

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

  model.subscribe user, game,  ->
    console.log model.get '_page.user'
    model.ref '_page.game', game
    model.ref '_page.user', user
    page.render 'game-page'