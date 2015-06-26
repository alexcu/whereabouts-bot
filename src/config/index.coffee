nconf = require 'nconf'
fs    = require 'fs'

nconf.file { file: 'res/config.json', readOnly: true }

module.exports = nconf.stores.file.store
