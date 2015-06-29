moment  = require 'moment'
slack   = require '../slack'

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
  mark: (userId, state, extraInfo) =>
    @users[userId] =
      user: slack.users[userId].profile # just include the profile
      state: state
      info: extraInfo
  usersForState: (state) =>
    (user for id, user of @users when user.state is state)

# Export singleton
module.exports = new StateTracker