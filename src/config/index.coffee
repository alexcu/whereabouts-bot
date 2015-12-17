pad  = require 'pad'
argv = require('yargs').argv

# Required config
config =
  botToken:   null
  serverPort: null
  expireTime: null
  authToken:  null
  listensTo:  null

expectedConfig =
  botToken:
    argv:     'slack-token'
    env:      'WHEREABOUTS_BOT_SLACK_TOKEN'
    describe: 'Token that allows your bot to connect to Slack'
    required: yes
  serverPort:
    argv:     'port'
    env:      'WHEREABOUTS_BOT_PORT'
    describe: 'The port in which the Whereabouts API should run (defaults to 3000)'
    default:  3000
    required: no
  expireTime:
    argv:     'expire-time'
    env:      'WHEREABOUTS_BOT_EXPIRE_TIME'
    describe: 'How often the bot should clear users whereabouts state, formatted as a cron-formatted time format (defaults to every 24 hrs)'
    default:  '00 00 * * *'
    required: no
  authToken:
    argv:     'auth-token'
    env:      'WHEREABOUTS_BOT_AUTH_TOKEN'
    describe: 'Authentication token for API requests'
    required: yes
  listensTo:
    argv:     'listen-to'
    env:      'WHEREABOUTS_BOT_LISTEN_TO'
    describe: 'Comma-separated list of the channels the bot should listen to'
    required: yes

# Just getting help?
if argv.help or argv.h
  for _, confVar of expectedConfig
    console.log "  --#{pad confVar.argv, 20}", confVar.describe
  process.exit 0
else
  for confKey, confVar of expectedConfig
    if process.env[confVar.env]?
      config[confKey] = process.env[confVar.env]
    if argv[confVar.argv]?
      config[confKey] = argv[confVar.argv]
    unless confVar.required
      config[confKey] = confVar.default
    if config[confKey] is null
      throw new Error "No value specified specified for required argument #{confVar.argv} or #{confVar.env} not specified in enviornment"
    if confKey is 'listensTo'
      config[confKey] = config[confKey].split(',')

module.exports = config
