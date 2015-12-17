_               = require 'underscore'
Q               = require 'q'
slack           = require '../slack'
DM              = require './dm'
{listensTo}     = require '../config'
{botResponses}  = require '../config'

###*
 * This class resolves questions from the bot and human responses to take
 * action from those responses
###
class HumanPrompter
  ###*
   * Generates a help message string
   * @return {String} The help text for when help is asked
  ###
  _helpMessage: ->
    formattedListensTo = []
    for id, channel of slack.channels when channel.name in listensTo
        formattedListensTo.push "<##{channel.id}|#{channel.name}>"
    "Hi! I'm #{slack.self.name}. Post in #{formattedListensTo.join ' or '} to inform the team of your whereabouts if you are late, sick, home or off-site and I'll confirm it with you.

    You can also bypass me (:cry:) by using the `/whereabouts [state]` slash command and set your own whereabouts by yourself."

  ###*
   * Responses to pick when talking to whereabouts bot without it asking human a question
   * @type {Array}
  ###
  @responses = [
    "Huh?"
    "Wha?"
    "Why are you talking to me?"
    "Hello!"
    "Can't you see I am working?"
    "I'm not one for making conversation."
  ]
  @responses = @responses.concat botResponses

  ###*
   * Constructs a new HumanPrompter and listens to the DM channel initated
   * between all users and the bot
  ###
  constructor: ->
    @users = {}
    slack.on 'message', (message) =>
      isDM = message.getChannelType() is "DM"
      # Create a new user if a new user starts talking to me
      hasSetup = (@_setupUser message.user if isDM)
      if hasSetup
        @pingHelp message.user

  ###*
   * Sets up a handler and prompter for the provided user
   * @param  {String} userId The id of the user to set up for
   * @return {Boolean}       Whether or not it was set up
  ###
  _setupUser: (userId) =>
    unless @users[userId]?
      hadToSetup = true
      @users[userId] =
        dm: new DM(userId)
        lastQuestion: undefined
      @users[userId].dm.on 'dmMessage', (message) =>
        @_parseMessage message, userId
    hadToSetup?

  ###*
   * Asks a question to a particular human in the DM channel
   * @param  {String} questionText      The question to ask
   * @param  {String} userId            The id of the user to ask this question to
   * @param  {RegularExpression} range  A regex that is to be tested on matching the string
   * @return {Promise}                  A promise to the deferred response
  ###
  ask: (questionText, userId, range) =>
    # Setup user if not setup before
    @_setupUser userId
    # Ignore the question if no response for two hours
    TWO_HOURS = 7200000
    @users[userId].lastQuestion =
      question: questionText
      expectedResponses: range
      timeout: setTimeout (=> @_giveUpAsking(userId)), TWO_HOURS
      deferred: Q.defer()
    # Ask the question
    @_sendMessage questionText, userId
    return @users[userId].lastQuestion.deferred.promise

  ###*
   * Sends a message to the user from the bot
   * @param  {String} messageText The text to send
   * @param  {String} userId      The id of the user to send the message to
  ###
  message: (messageText, userId) =>
    # Setup user if not setup before
    @_setupUser userId
    @users[userId].dm.sendMessage messageText

  ###*
   * Sends a give up asking question message to the given user
   * @param  {String} userId The id of the user to send the message to
  ###
  _giveUpAsking: (userId) =>
    @message "Fine, don't answer me :pensive: :broken_heart:", userId
    clearTimeout @users[userId].lastQuestion.timeout
    # reject the promise
    @users[userId].lastQuestion.deferred.reject()
    @users[userId].lastQuestion = undefined

  ###*
   * Pings the user with the help text
   * @param  {String} userId The id of the user to send the message to
  ###
  pingHelp: (userId) =>
    @message @_helpMessage(), userId

  ###

  @param message [object] The message to check
  @param userId [string] Who to parse from
  ###
  ###*
   * Parse a message for a suitable human response
   * @param  {Object} message The message object to check
   * @param  {String} userId  Who to parse the message from
  ###
  _parseMessage: (message, userId) =>
    return if message.user isnt userId
    messageText = message.text.toLowerCase()
    return @pingHelp userId if messageText is 'help'
    questionObj = @users[userId].lastQuestion
    # talking to bot without a question asked?
    unless questionObj?
      return @_sendMessage _.sample(HumanPrompter.responses), userId
    matches = questionObj.expectedResponses.exec messageText
    if matches? and matches.length > 0
      # resolve the promise with the first match
      @users[userId].lastQuestion.deferred.resolve(matches[0])
      # remove this question asked and clear the timeout
      clearTimeout @users[userId].lastQuestion.timeout
      @users[userId].lastQuestion = undefined
    else
      # unexpected response
      @_sendMessage "Sorry I don't understand. Answer with one of `#{questionObj.expectedResponses}`.", userId
      @_sendMessage questionObj.question, userId

# Singleton parser
module.exports = new HumanPrompter()
