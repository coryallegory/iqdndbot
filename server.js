require('coffee-script/register');
require('newrelic');
// hubot.coffee will be created by Azure at deploy time
module.exports = require('hubot/bin/hubot.coffee');
