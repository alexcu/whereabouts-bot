slack              = require '../slack'
WhereaboutsStates  = require './whereabouts-states'
{CronJob}          = require 'cron'
{expireTime}       = require '../config'
###
This class tracks the state of users
###
class StateTracker
  constructor: ->
    @users = {}
    if expireTime?
      console.log "Setting up expire to 00 #{expireTime}"
      try
        job = new CronJob '00 ' + expireTime, =>
          @users = {}
        job.start()
      catch e
        throw Error "Invalid cron time for `expireTime`"

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