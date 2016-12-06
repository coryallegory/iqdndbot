# Description:
#   Look up DnD 5e spells
#
# Commands:
#   hubot spell list - Provide link to spell resource
#   hubot spell <name> - Retrieve spell details
#
# Author:
#   coryallegory
#

toTitleCase = (str) ->
  return str.replace /\w\S*/g, (txt) ->
    return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase()

stripHtml = (str) ->
  str = str.replace /<\/?br>/, "\n"
  str = str.replace /<p>/, "\n\n"
  str = str.replace /<[A-Za-z/][^<>]*>/, ""
  return str


spells = {}


module.exports = (robot) ->

  loadSpells = () ->
    robot.http("https://donjon.bin.sh/5e/spells/spell_data.js")
      .get() (err, res, body) ->
        if res.statusCode isnt 200
          console.log "Spells data request didn't come back HTTP 200 :("
        else
          a = body.indexOf "{"
          b = body.lastIndexOf "}"
          data_string = body.substring a, b+1
          spells = JSON.parse( data_string )
          for k,v of spells
            spells[k].classes = []
            spells[k].description = "No description available."
          console.log "Spell data loaded"
  loadSpells()

  getSpell = (name, callback) ->
    if not spells?
      console.log "Spells not loaded"
      loadSpells()
      return
    spell = spells[name]
    console.log spell
    if not spell? or spell.filled
      callback(spell)
      return
    robot.http( "https://donjon.bin.sh/5e/spells/rpc.cgi?name=" + name.replace(" ", "+") )
      .get() (err, res, body) ->
        if res.statusCode isnt 200
          console.log "Spell data request didn't come back HTTP 200 :("
        else
          data = JSON.parse(body)
          spell.classes = data.Class
          spell.description = stripHtml(data.Description)
          spell.filled = true
        callback(spell)
  

  robot.respond /spell (.*)/i, (msg) ->
    name = toTitleCase msg.match[1]

    if name == "List"
      msg.send "Spell Reference: https://donjon.bin.sh/5e/spells/"
      return

    getSpell name, (spell) ->
      if not spell?
        msg.send "Spell [" + name + "] could not be found."
      else
        summary = name + "\n>>>\n"
        summary += "_" + spell.school + " " + spell.level + " (" + spell.classes.join(", ") + ")_\n"
        summary += "*Casting Time:* "
        if spell.concentration == "yes"
          summary += "Concentration, "
        summary += spell.casting_time + "\n"
        summary += "*Range:* " + spell.range + "\n"
        summary += "*Components:* " + spell.components + "\n"
        summary += "*Duration:* " + spell.duration + "\n"
        summary += spell.description

        msg.send summary
