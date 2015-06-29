slack         = require '../slack'
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
  @WhereaboutsPrompterForState[@WhereaboutsStates.RUNNING_LATE] =
    responses:  yesNoResponse
    question:   "Are you running late or coming in later today?"
    actions:
      affirmative: (userId) ->
        console.log 'TODO: Set late status'
        sendThanks(userId)
      negative:    sendOkay
  # Staying Home Action
  @WhereaboutsPrompterForState[@WhereaboutsStates.STAYING_HOME] =
    responses: yesNoResponse
    question: "Are you staying home today?"
    actions:
      affirmative: (userId) ->
        console.log 'Asking if home'
        HumanPrompter.ask("Will you be working from home?", userId, yesNoResponse).then ((response) ->
          isWorkingAtHome = isAffirmative response
          console.log 'TODO: Set home[true] working[isWorkingAtHome]'
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