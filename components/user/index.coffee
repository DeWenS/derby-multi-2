module.exports = class User

  name: 'user'
  view: __dirname

  init: () ->
    @userId = @model.root.get '_session.userId'
    @user = @model.root.get '_page.user'
#    @user = @model.at 'users.' + @userId
    @model.ref 'user', @user

  saveParams: ->
    name = @model.get 'name'
    @model.fetch @user , ->
      @user.set {'name': name}
#    @user.set {'name': name}

