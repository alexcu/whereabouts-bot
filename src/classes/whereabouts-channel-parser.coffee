slack             = require '../slack'
WhereaboutsStates = require './whereabouts-states'
HumanPrompter     = require './human-prompter'
StateTracker      = require './state-tracker'

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
      throw new Error "#{slack.self.name} is not a member of #{listeningTo} or #{listeningTo} could not be found. Please be sure you invite the bot by entering '@#{slack.self.name}' into \##{listeningTo}."
  ###
  The variant states for outstanding whereabouts
  ###
  RUNNING_LATE    = WhereaboutsStates.RUNNING_LATE
  STAYING_HOME    = WhereaboutsStates.STAYING_HOME
  WORKING_AT_HOME = WhereaboutsStates.WORKING_AT_HOME
  OFFSITE         = WhereaboutsStates.OFFSITE
  OUT_OF_OFFICE   = WhereaboutsStates.OUT_OF_OFFICE

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
    'sick':         STAYING_HOME
    'unwell':       STAYING_HOME
    'coming in':    STAYING_HOME
    'in lieu':      STAYING_HOME
    'leave':        STAYING_HOME
    'day off':      STAYING_HOME
    'away':         STAYING_HOME
    # offsite
    'offsite':      OFFSITE
    'off site':     OFFSITE
    'off-site':     OFFSITE
    # out
    'heading out':  OUT_OF_OFFICE
    'out':          OUT_OF_OFFICE

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
    question:   "Will you be in late today?"
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
            StateTracker.mark userId, if isWorkingAtHome then WORKING_AT_HOME else STAYING_HOME
            sendThanks(userId)
        )
      negative: sendOkay
  # Off site
  @WhereaboutsPrompterForState[OFFSITE] =
    responses: yesNoResponse
    question: "Are you working off-site today?"
    actions:
      affirmative: (userId) ->
        StateTracker.mark userId, OFFSITE
        sendThanks(userId)
      negative:    sendOkay
  # Out
  @WhereaboutsPrompterForState[OUT_OF_OFFICE] =
    responses: yesNoResponse
    question: "Are you heading out of the office for a bit?"
    actions:
      affirmative: (userId) ->
        StateTracker.mark userId, OUT_OF_OFFICE
        sendThanks(userId)
      negative:    sendOkay

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
