moment             = require 'moment'
slack              = require '../slack'
WhereaboutsStates  = require './whereabouts-states'

###
This class tracks the state of users
###
class StateTracker
  constructor: ->
    @users = {}
    resetCheck = =>
      isMidnight = moment().format("h:mm:ss") == "0:00:00"
      @users = {} if isMidnight
    # reset the user states at midnight
    setInterval(resetCheck, 1000)
  ###
  Mark a user's state
  @param  userId  [string]            The user to mark
  @param  state   [WhereaboutsState]  The state to set as
  ###
  mark: (userId, state) =>
    unless state.toUpperCase() in Object.keys WhereaboutsStates
      throw Error "Invalid state provided for marking #{state}"
    @users[userId] =
      user: slack.users[userId].profile # just include the profile
      state: state
  ###
  Clear a user's state
  @param  userId  [string]  The user to clear
  ###
  clear: (userId) =>
    if @users[userId]?
      delete @users[userId]
  ###
  Retrieves all users whose state match the state provided
  @param state  [string]  The state to check
  ###
  usersForState: (state) =>
    (user for id, user of @users when user.state is state)

# Export singleton
module.exports = new StateTracker