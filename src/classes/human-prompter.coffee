slack           = require '../slack'
DM              = require './dm'
{EventEmitter}  = require 'events'

###
This class resolves questions/responses
###
class HumanPrompter extends EventEmitter
  ###
  @param userId [string] Who to confirm state with
  @param questionText [string] The question text
  @param range [array] An array of acceptable responses for the question
  ###
  constructor: (userId, @questionText, @range) ->
    @_dm = new DM(userId)
    # Ask the question
    @_dm.sendMessage @questionText
    @_dm.on 'dmMessage', @parseMessage

  ###
  Parse a message for a suitable human response
  Emits a 'messageParsed' with given response
  @param message [string] The message to check
  ###
  parseMessage: (message) =>
    return if message.user is slack.self.id
    messageText = message.text.toLowerCase()
    for response in @range
      if messageText.indexOf(response) > -1
        return @emit 'messageParsed', response
    @_dm.sendMessage "Sorry I don't understand. Answer with one of #{@range.join(', ')}."
    @_dm.sendMessage @questionText
    @emit 'messageRejected'

module.exports = HumanPrompter