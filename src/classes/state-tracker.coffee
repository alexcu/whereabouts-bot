slack                               = require '../slack'
WhereaboutsStates                   = require './whereabouts-states'
{CronJob}                           = require 'cron'
{expireTime, redisHost, redisPort}  = require '../config'
Q                                   = require 'q'
redis                               = require('promise-redis')(Q.Promise);


###*
 * This class tracks the states of users
###
class StateTracker
  ###*
   * Constructs a new StateTracker
  ###
  constructor: ->
    @_redis = redis.createClient({ host: redisHost, port: redisPort })
    @_redis.on 'error', @_logError
    if expireTime?
      try
        job = new CronJob '00 ' + expireTime, @clear
        job.start()
      catch e
        throw Error "Invalid cron time for `expireTime`"

  ###*
   * Mark a user's state
   * @param  {String}             userId  The id of the user to mark
   * @param  {WhereaboutsStates}  state   The state to mark the user with
   * @return {Promise}                    A promise to setting the state
  ###
  mark: (userId, state) =>
    @clear(userId).then (numChanged) =>
      @_redis.SADD(state, userId).catch(@_logError)

  ###*
   * Resets a user's state
   * @param {String} userId   The id of the user to clear
   *                          If not provided, it will delete all states for
   *                          all users.
  ###
  clear: (userId) =>
    if userId?
      @stateForUser(userId).then (state) =>
        @_redis.SREM(state, userId).catch(@_logError)
    else
      for state of WhereaboutsStates
        @_redis.DEL(state).catch(@_logError)

  ###*
   * Gets the state for the user id specified
   * @param  {String} userId The id to get the state for
   * @return {Promise}       A promise to the state. Resolves to null if not found
  ###
  stateForUser: (userId) =>
    deferred = Q.defer()
    promises = (@_redis.SISMEMBER(state, userId) for _, state of WhereaboutsStates)
    Q.all(promises).catch(@_logError).then (responses) =>
      stateIndex = responses.indexOf 1
      # Not found?
      if stateIndex is -1
        deferred.resolve null
      else
        key = Object.keys(WhereaboutsStates)[stateIndex]
        deferred.resolve WhereaboutsStates[key]
    deferred.promise

  ###*
   * Retrieves all users whose state match the state provided
   * @param  {WhereaboutsStates} state  The state of users to search for
   * @return {Promise}                  A promise to the result
  ###
  usersForState: (state) =>
    @_redis.SMEMBERS state

  ###*
   * Log a redis error
   * @param  {Error} err Error to log
  ###
  _logError: (err) =>
    console.error "StateTracker Redis Client Error:", err

# Export singleton
module.exports = new StateTracker
