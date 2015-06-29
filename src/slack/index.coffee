###
This module exports the client for communicating with Slack
###
config      = require '../config'
SlackClient = require 'slack-client'

slack = new SlackClient config.botToken, config.autoReconnect

slack.on 'error', (error) ->
  console.error "Error: #{JSON.stringify error}"

# Export the slack bot
module.exports = slack