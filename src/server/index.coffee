{serverPort}              = require '../config'
express                   = require 'express'
app                       = express()
StateTracker              = require '../classes/state-tracker'
WhereaboutsChannelParser  = require '../classes/whereabouts-channel-parser'

app.use express.bodyParser()

RUNNING_LATE =  WhereaboutsChannelParser.WhereaboutsStates.RUNNING_LATE
STAYING_HOME =  WhereaboutsChannelParser.WhereaboutsStates.STAYING_HOME
WORKING_AT_HOME = WhereaboutsChannelParser.WhereaboutsStates.WORKING_AT_HOME

###
GET /states/
Retrieves each user for each state
###
app.get '/states/', (req, res) ->
  stateInfo = {}
  for _, state of WhereaboutsChannelParser.WhereaboutsStates
    stateInfo[state] = StateTracker.usersForState state
  res.send stateInfo

###
POST /state/
Update a state for a user
###
app.post '/states/', (req, res) ->
  userId = req.body.user_id
  param  = req.body.text
  ACCEPTED_PARAMS = ['home', 'sick', 'late', 'clear']
  unless param in ACCEPTED_PARAMS
    return res.status(400).send("Unacceptable parameter. Set to one of #{ACCEPTED_PARAMS.join ', '}")
  switch param
    when 'home'
      StateTracker.mark userId, STAYING_HOME, WORKING_AT_HOME
    when 'sick'
      StateTracker.mark userId, STAYING_HOME
    when 'late'
      StateTracker.mark userId, RUNNING_LATE
    when 'clear'
      StateTracker.clear userId
  res.status(200).send "Whereabouts #{if param is 'clear' then 'cleared' else 'updated'}."

# Open the server
server = app.listen serverPort, ->
  host = server.address().address
  port = server.address().port
  console.log 'Listening at http://%s:%s', host, port

module.exports =
  server: server
  app: app