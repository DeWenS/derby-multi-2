module.exports = class User

  name: 'user'
  view: __dirname

  init: () ->
    @userId = @model.root.get '_session.userId'
    @user = @model.root.at '_page.user'
    @model.ref 'user', @user
    is_prof = @model.get('user.prof');
    @model.set 'is_professor', is_prof

  saveParams: ->
    name = @model.get 'name'
    is_professor = @model.get 'is_professor'
    if name
      @user.set 'name', name
    @user.set 'prof', is_professor
    @model.set 'name', null
