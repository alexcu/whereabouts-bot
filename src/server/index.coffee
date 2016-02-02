{serverPort}       = require '../config'
{authToken}        = require '../config'
express            = require 'express'
app                = express()
slack              = require '../slack'
bodyParser         = require 'body-parser'
StateTracker       = require '../classes/state-tracker'
HumanPrompter      = require '../classes/human-prompter'
WhereaboutsStates  = require '../classes/whereabouts-states'

###
The variant states for outstanding whereabouts
###
RUNNING_LATE    = WhereaboutsStates.RUNNING_LATE
STAYING_HOME    = WhereaboutsStates.STAYING_HOME
WORKING_AT_HOME = WhereaboutsStates.WORKING_AT_HOME
OFFSITE         = WhereaboutsStates.OFFSITE
OUT_OF_OFFICE   = WhereaboutsStates.OUT_OF_OFFICE

app.use bodyParser.urlencoded { extended: true }

###
GET /states
Retrieves each user for each state
###
app.get '/states', (req, res) ->
  stateInfo = {}
  for _, state of WhereaboutsStates
    stateInfo[state] = StateTracker.usersForState state
  res.send stateInfo

###
POST /states
Update a state for a user
###
app.post '/states', (req, res) ->
  unless req.body.token is authToken
    return res.status(400).send("Invalid auth token provided")
  userId = req.body.user_id
  unless slack.users[userId]?
    return res.status(400).send("No such user with id #{userId}")
  param  = req.body.text
  ACCEPTED_PARAMS = ['home', 'sick', 'late', 'out', 'offsite', 'clear', 'help']
  unless param in ACCEPTED_PARAMS
    return res.status(400).send("Unacceptable parameter. Set to one of #{ACCEPTED_PARAMS.join ', '}")
  switch param
    when 'help'
      HumanPrompter.pingHelp userId
    when 'out'
      StateTracker.mark userId, OUT_OF_OFFICE
    when 'offsite'
      StateTracker.mark userId, OFFSITE
    when 'home'
      StateTracker.mark userId, WORKING_AT_HOME
    when 'sick'
      StateTracker.mark userId, STAYING_HOME
    when 'late'
      StateTracker.mark userId, RUNNING_LATE
    when 'clear'
      StateTracker.clear userId
  if param isnt 'help'
    msg = "Whereabouts #{if param is 'clear' then 'cleared' else 'updated'}."
  else
    msg = "Usage: `#{ACCEPTED_PARAMS.join('`, `')}`"
  res.status(200).send msg

# Open the server
server = app.listen serverPort, ->
  host = server.address().address
  port = server.address().port
  console.log 'Listening at http://%s:%s', host, port

module.exports =
  server: server
  app: app
