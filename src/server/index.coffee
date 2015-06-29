{serverPort}              = require '../config'
express                   = require 'express'
app                       = express()
WhereaboutsChannelParser  = require '../classes/whereabouts-channel-parser'
StateTracker              = require '../classes/state-tracker'

###
GET /states/
Retrieves the different keys required to get states for users
###
app.get '/states/', (req, res) ->
  res.send (v for k, v of WhereaboutsChannelParser.WhereaboutsStates)

###
GET /users/:state
Retrieves the users with the given state
###
app.get '/users/:state', (req, res) ->
  res.send StateTracker.usersForState req.params.state


# Open the server
server = app.listen serverPort, ->
  host = server.address().address
  port = server.address().port
  console.log 'Example app listening at http://%s:%s', host, port

module.exports =
  server: server
  app: app