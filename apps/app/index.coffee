derby = require 'derby'

app = module.exports = derby.createApp 'app', __filename


app.use require 'derby-router'
app.use require 'derby-debug'
app.serverUse module, 'derby-jade'
app.serverUse module, 'derby-stylus'

app.component  require '../../components/user'

app.loadViews __dirname + '/views'
app.loadStyles __dirname + '/styles'

app.get 'home', '/', (page, model, params) ->
  userId = model.get '_session.userId'
  user = model.at 'users.' + userId
  model.subscribe user, ->
    model.ref '_page.user', user
    page.render('home')

