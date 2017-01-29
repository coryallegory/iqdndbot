require('coffee-script/register');
// hubot.coffee will be created by Azure at deploy time
module.exports = require('hubot/bin/hubot.coffee');

require('newrelic');
