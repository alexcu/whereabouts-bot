slack              = require '../slack'
WhereaboutsStates  = require './whereabouts-states'
{CronJob}          = require 'cron'
{expireTime}       = require '../config'

###*
 * This class tracks the states of users
###
class StateTracker
  ###*
   * Constructs a new StateTracker
  ###
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

  ###*
   * Mark a user's state
   * @param  {String}             userId  The id of the user to mark
   * @param  {WhereaboutsStates}  state   The state to mark the user with
   * @return {Boolean}                    Whether or not the state was set
  ###
  mark: (userId, state) =>
    unless state.toUpperCase() in Object.keys WhereaboutsStates
      return false
    @users[userId] =
      user: slack.users[userId].profile # just include the profile
      state: state
    true

  ###*
   * Resets a user's state
   * @param  {String} userId  The id of the user to clear
  ###
  clear: (userId) =>
    if @users[userId]?
      delete @users[userId]

  ###*
   * Retrieves all users whose state match the state provided
   * @param  {WhereaboutsStates} state  The state of users to search for
  ###
  usersForState: (state) =>
    (user for id, user of @users when user.state is state)

# Export singleton
module.exports = new StateTracker
