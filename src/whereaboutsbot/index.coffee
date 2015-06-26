###
This index script loads all modules in the current directory into a key-value pair object that is exported.
###

fs = require "fs"
path = require "path"
helpers = {}

fs.readdirSync __dirname
  .filter (file) -> file isnt path.basename(__filename)
  .map (file) -> path.basename(file, path.extname file)
  .forEach (name) -> helpers[name] = require "./#{name}"

module.exports = helpers