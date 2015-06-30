moment             = require 'moment'
slack              = require '../slack'
WhereaboutsStates  = require './whereabouts-states'

###
The variant states for outstanding whereabouts
###
RUNNING_LATE    = WhereaboutsStates.RUNNING_LATE
STAYING_HOME    = WhereaboutsStates.STAYING_HOME
WORKING_AT_HOME = WhereaboutsStates.WORKING_AT_HOME

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