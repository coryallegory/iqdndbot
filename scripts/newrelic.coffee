# Description:
#   Initialize newrelic monitoring
#
# Dependencies:
#   newrelic
#
# Configuration:
#   NEW_RELIC_APP_NAME environment var required
#   NEW_RELIC_LICENSE_KEY environment var required
#
# Commands:
#   none
#

newrelic = require('newrelic')
module.exports = (robot) ->
