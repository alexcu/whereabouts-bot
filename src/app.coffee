slack                     = require './slack'
WhereaboutsChannelParser  = require './classes/whereabouts-channel-parser'
{listensTo}               = require './config'

# Login to Slack
slack.login()

# When initialised
slack.on 'open', ->
  # Initialise listening to input from channels
  parsers = []
  for channel in listensTo
    parsers.push new WhereaboutsChannelParser channel
  slack.on 'message', (message) ->
    for parser in parsers
      parser.onMessage message