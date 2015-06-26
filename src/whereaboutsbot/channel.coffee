{listensTo} = require '../config'
slack       = require '../slack'

HumanPrompter = require './human-prompter'

###
This class parses text from the whereabouts channel
###
class WhereaboutsChannelParser
  ###
  @param listeningTo  The channel name the parser listens to
  ###
  constructor: (listeningTo) ->
    @channel = (channel for id, channel of slack.channels when channel.name is listeningTo and channel.is_member)[0]
    unless @channel?
      throw Error "#{slack.self.name} is not a member of #{listeningTo} or #{listeningTo} could not be found"

  ###
  The variant states for outstanding whereabouts
  ###
  @WhereaboutsStates:
    RUNNING_LATE: 'running_late'
    STAYING_HOME: 'staying_home'

  ###
  Keywords detected for
  ###
  @WhereaboutsKeywords:
    # running late
    'late':         @WhereaboutsStates.RUNNING_LATE
    'later':        @WhereaboutsStates.RUNNING_LATE
    'a while':      @WhereaboutsStates.RUNNING_LATE
    'soon':         @WhereaboutsStates.RUNNING_LATE
    # staying home
    'home':         @WhereaboutsStates.STAYING_HOME
    'not feeling':  @WhereaboutsStates.STAYING_HOME
    'won\'t be in': @WhereaboutsStates.STAYING_HOME
    'unwell':       @WhereaboutsStates.STAYING_HOME
    'coming in':    @WhereaboutsStates.STAYING_HOME
    'in lieu':      @WhereaboutsStates.STAYING_HOME
    'leave':        @WhereaboutsStates.STAYING_HOME
    'day off':      @WhereaboutsStates.STAYING_HOME

  ###
  Parses messages, returning the state for a matched keyword
  @param text Text to parse
  @returns The state of a matched keyword
  ###
  parseMessage: (text) =>
    text = text.toLowerCase()
    for keyword, state of WhereaboutsChannelParser.WhereaboutsKeywords
      return state if text.indexOf(keyword) > -1

  ###
  Listening events for handling new messages
  @param message  The incoming message
  ###
  onMessage: (message) =>
    state = @parseMessage message.text if message.channel is @channel.id
    unless state?
      return
    userId = message.user
    responses = ['yes', 'y', 'no', 'no']
    # Set up a state prompter
    switch state
      when WhereaboutsChannelParser.WhereaboutsStates.RUNNING_LATE
        question = "Are you running late or coming in later today? [yes or no]"
      when WhereaboutsChannelParser.WhereaboutsStates.STAYING_HOME
        question = "Are you staying home today? [yes or no]"
    prompter = new HumanPrompter userId, question, responses
    prompter.on 'messageParsed', (response) ->
      console.log "User response:", response


###
Initialise listening to input
###
module.exports.initialise = ->
  parsers = []
  for channel in listensTo
    parsers.push new WhereaboutsChannelParser channel
  slack.on 'message', (message) ->
    for parser in parsers
      parser.onMessage message
