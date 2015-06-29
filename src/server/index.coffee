{serverPort}              = require '../config'
express                   = require 'express'
app                       = express()
WhereaboutsChannelParser  = require '../classes/whereabouts-channel-parser'
StateTracker              = require '../classes/state-tracker'

###
GET /states/
Retrieves each user for each state
###
app.get '/states/', (req, res) ->
  stateInfo = {}
  for _, state of WhereaboutsChannelParser.WhereaboutsStates
    stateInfo[state] = StateTracker.usersForState state
  res.send stateInfo


# Open the server
server = app.listen serverPort, ->
  host = server.address().address
  port = server.address().port
  console.log 'Listening at http://%s:%s', host, port

module.exports =
  server: server
  app: app