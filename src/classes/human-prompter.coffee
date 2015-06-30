_               = require 'underscore'
Q               = require 'q'
slack           = require '../slack'
DM              = require './dm'
{listensTo}     = require '../config'
{botResponses}  = require '../config'


###
This class resolves questions/responses
###
class HumanPrompter
  ###
  @returns The help text for when help is initiated
  ###
  _helpMessage: ->
    formattedListensTo = []
    for id, channel of slack.channels when channel.name in listensTo
        formattedListensTo.push "<##{channel.id}|#{channel.name}>"
    "Hi! I'm #{slack.self.name}. Post in #{formattedListensTo.join ' or '} to inform the team of your whereabouts if you are late or at home and I'll confirm it with you. You can also bypass me (:cry:) by using the `/whereabouts [state]` slash command."

  ###
  Responses to pick when talking to whereabouts bot without it asking human a question
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

  constructor: ->
    @users = {}
    slack.on 'message', (message) =>
      isDM = message.getChannelType() is "DM"
      # Create a new user if a new user starts talking to me
      hasSetup = (@_setupUser message.user if isDM)
      if hasSetup
        @_sendMessage @_helpMessage(), message.user

  ###
  Sets up a prompter for a user
  @param userId [string]  The user to setup for
  @returns whether or not it was set up
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

  ###
  Ask a question to a particular human
  @param questionText [string] The question text
  @param userId [string] Who to ask question to
  @param range [RegEx] A regex that is to be tested on matching the string
  @returns A promise to the deferred response
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

  ###
  Sends a message to the user from the bot (public method)
  @param  messageText [string]  text to send
  @param  userId  [string]  who to send the message to
  ###
  message: (messageText, userId) =>
    # Setup user if not setup before
    @_setupUser userId
    @_sendMessage messageText, userId


  ###
  Sends a message to the user from the bot
  @param  messageText [string]  text to send
  @param  userId  [string]  who to send the message to
  ###
  _sendMessage: (messageText, userId) =>
    @users[userId].dm.sendMessage messageText

  ###
  Give up question
  @param userId [string] Who to give up on
  ###
  _giveUpAsking: (userId) =>
    @_sendMessage "Fine, don't answer me :pensive: :broken_heart:", userId
    clearTimeout @users[userId].lastQuestion.timeout
    # reject the promise
    @users[userId].lastQuestion.deferred.reject()
    @users[userId].lastQuestion = undefined

  ###
  Parse a message for a suitable human response
  @param message [object] The message to check
  @param userId [string] Who to parse from
  ###
  _parseMessage: (message, userId) =>
    return if message.user isnt userId
    if message.text is 'help'
      return @_sendMessage @_helpMessage(), userId
    questionObj = @users[userId].lastQuestion
    # talking to bot without a question asked?
    unless questionObj?
      return @_sendMessage _.sample(HumanPrompter.responses), userId
    messageText = message.text.toLowerCase()
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