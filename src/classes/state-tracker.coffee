moment                    = require 'moment'
slack                     = require '../slack'
WhereaboutsChannelParser  = require '../classes/whereabouts-channel-parser'

# Alises
RUNNING_LATE =  WhereaboutsChannelParser.WhereaboutsStates.RUNNING_LATE
STAYING_HOME =  WhereaboutsChannelParser.WhereaboutsStates.STAYING_HOME
WORKING_AT_HOME = WhereaboutsChannelParser.WhereaboutsStates.WORKING_AT_HOME

###
This class tracks the state of users
###
class StateTracker
  constructor: ->
    @users = {}
    # reset the user states at midnight
    setTimeout(
       (-> @user = {}),
       moment("24:00:00", "hh:mm:ss").diff(moment(), 'seconds')
    )
  ###
  Mark a user's state
  @param  userId  [string]  The user to mark
  @param  state   [string]  The state to set as (one of STAYING_HOME or RUNNING_LATE)
  @param  extraInfo [string]  Include WORKING_AT_HOME here if STAYING_HOME and working
  ###
  mark: (userId, state, extraInfo) =>
    unless state in [RUNNING_LATE, STAYING_HOME] or (extraInfo? and extraInfo isnt WORKING_AT_HOME)
      throw Error "Invalid state provided for marking #{state} (extraInfo=#{extraInfo})"
    @users[userId] =
      user: slack.users[userId].profile # just include the profile
      state: state
      info: extraInfo
  ###
  Clear a user's state
  @param  userId  [string]  The user to clear
  ###
  clear: (userId) =>
    delete @users[userId]
  ###
  Retrieves all users whose state match the state provided
  @param state  [string]  The state to check
  ###
  usersForState: (state) =>
    (user for id, user of @users when user.state is state)

# Export singleton
module.exports = new StateTracker