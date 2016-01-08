global.config = require 'config'

UserModel = require '../../src/models/internal_storage/user'

userModel = new UserModel

params = {
  username: 'admin'
  password: 'Ra1234'
  first_name: 'Raghavendra'
  last_name: 'Karunanidhi'
  role: 'admin'
}

userModel.getOne {username: params.username}, (e, user)->
  if e?
    console.log e
    process.exit(1)

  if user?
    console.log 'Super admin already created'
    process.exit(0)

  userModel.create params, (e)->
    if e?
      console.log e
      process.exit(1)
    else
      console.log 'Super admin user created successfully.'
      process.exit(0)
