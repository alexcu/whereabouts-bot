slack           = require '../slack'
Q               = require 'q'
{EventEmitter}  = require 'events'

###
This class is a simple wrapper around the slack DM
###
class DM extends EventEmitter
  ###
  @param userId [string] The id of the person to DM to
  ###
  constructor: (userId) ->
    @user = slack.users[userId]
    unless @user?
      throw Error "That can't happen - user id #{userId} not found!"
    # Load the DM channel from slack DMs if there
    @_dmChannel = (dm for id, dm of slack.dms when dm.user is @user.id)[0]
    # Forward the message only if received from another user in this DM channel
    slack.on 'message', (message) =>
      # Grab the DM channel
      if message.getChannelType() is "DM" and message.user is userId
        @emit 'dmMessage', message
  ###
  Prompt a message in the DM
  @param message [string] The message to prompt
  ###
  sendMessage: (message) =>
    # Load the DM channel from slack DMs if there
    send = =>
      @_dmChannel.send message
    # If we need to open a new DM channel, then we open one
    unless @_dmChannel?
      d = Q.defer()
      slack.openDM @user.id, (dm) ->
        @_dmChannel = slack.dms[dm.channel.id]
        d.resolve()
      d.promise.then send
    else
      send()

module.exports = DM