slack         = require '../slack'
HumanPrompter = require './human-prompter'
StateTracker  = require './state-tracker'

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
    WORKING_AT_HOME: 'working_at_home'
  # Alises
  RUNNING_LATE =  WhereaboutsChannelParser.WhereaboutsStates.RUNNING_LATE
  STAYING_HOME =  WhereaboutsChannelParser.WhereaboutsStates.STAYING_HOME
  WORKING_AT_HOME = WhereaboutsChannelParser.WhereaboutsStates.WORKING_AT_HOME

  ###
  Keywords detected for
  ###
  @WhereaboutsKeywords:
    # running late
    'late':         RUNNING_LATE
    'later':        RUNNING_LATE
    'a while':      RUNNING_LATE
    'soon':         RUNNING_LATE
    # staying home
    'home':         STAYING_HOME
    'not feeling':  STAYING_HOME
    'won\'t be in': STAYING_HOME
    'unwell':       STAYING_HOME
    'coming in':    STAYING_HOME
    'in lieu':      STAYING_HOME
    'leave':        STAYING_HOME
    'day off':      STAYING_HOME

  ###
  Actions for DM responses
  ###
  @WhereaboutsPrompterForState: {}

  yesNoResponse = /yes|y|yep|no|n|nup|nope/
  sendThanks    = (userId) ->
    HumanPrompter.message "Thanks for letting me know :smile:", userId
  sendOkay      = (userId) ->
    HumanPrompter.message "Okay, just checking :simple_smile:", userId
  isAffirmative = (response) ->
    response.charAt(0) is 'y'
  # Running Late Action
  @WhereaboutsPrompterForState[RUNNING_LATE] =
    responses:  yesNoResponse
    question:   "Are you running late or coming in later today?"
    actions:
      affirmative: (userId) ->
        StateTracker.mark userId, RUNNING_LATE
        sendThanks(userId)
      negative:    sendOkay
  # Staying Home Action
  @WhereaboutsPrompterForState[STAYING_HOME] =
    responses: yesNoResponse
    question: "Are you staying home today?"
    actions:
      affirmative: (userId) ->
        HumanPrompter.ask("Will you be working from home?", userId, yesNoResponse).then (
          (response) ->
            isWorkingAtHome = isAffirmative response
            StateTracker.mark userId, STAYING_HOME, (if isWorkingAtHome then WORKING_AT_HOME else undefined)
            sendThanks(userId)
        )
      negative: sendOkay

  ###
  Parses messages, returning the state for a matched keyword
  @param text Text to parse
  @returns The state of a matched keyword
  ###
  parseMessage: (text) =>
    if text?
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
    prompter = WhereaboutsChannelParser.WhereaboutsPrompterForState[state]
    HumanPrompter.ask(prompter.question, userId, prompter.responses).then (
      (response) ->
        method = if isAffirmative response then 'affirmative' else 'negative'
        prompter.actions[method](userId)
    )

module.exports = WhereaboutsChannelParser