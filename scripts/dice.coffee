# Description:
#   Have Hubot roll dice with optional modifier.
#   Case and whitespace insensitive.
#   An extension of hubot-scripts/dice.coffee
#
#   > hubot roll d6
#   I rolled 5. [5]
#
#   > hubot roll 2d6
#   I rolled 6. [4,2]
#
#   > hubot roll 2x 3d6 + 2 for luck
#   I rolled (for luck):
#   11 [4,2,3]+2
#   17 [6,6,3]+2
#
#   > hubot advantage
#   I rolled 2. [2,20]
#
#   > hubot disadvantage +8 whether hits
#   I rolled 25 (whether hits). [10,17]+8
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot roll [<r>x] [<c>]d<s> [<+|-> <m>] [<t>] - Roll <s> sided dice. Optional roll count <c>, optional <+|-> modifier, optionally repeat roll <r> times, optional label text <t>.
#   hubot check [<r>x] [<c>]d<s> [<+|-> <m>] [<t>] - Alias for 'hubot roll'
#   hubot advantage [<+|-> <m>] [<t>] - Roll 2xd20, take the higher value and apply modifier. Optional label text may be appended.
#   hubot disadvantage [<+|-> <m>] [<t>] - Roll 2xd20, take the lower value and apply modifier. Optional label text may be appended.
#
# Author:
#   coryallegory
#

roll = (sides) ->
  1 + Math.floor(Math.random() * sides)

rollSet = (dice, sides) ->
  roll(sides) for i in [0...dice]

rollSets = (count, dice, sides) ->
  rollSet(dice, sides) for [0...count]

setTotals = (sets) ->
  sets.map( (set) -> (set.reduce (a,b) -> a+b) )

maxValue = (array) ->
  Math.max.apply(Math, array)

minValue = (array) ->
  Math.min.apply(Math, array)

rejectionResponse = (queryValues) ->
  if queryValues.repeats < 1
    return "I don't know how to roll less than one set of rolls."
  if queryValues.repeats > 100
    return "I'm not going to roll more than 100 sets of rolls for you."
  if queryValues.sides < 1
    return "I don't know how to roll a zero-sided die."
  if queryValues.dice > 50
    return "I'm not going to roll more than 50 dice for you."

critAlert = (rollValue, queryValues) ->
  if ( queryValues.sides == 20 && queryValues.dice == 1 )
    if rollValue == 20
      return "*Crit!* "
    else if rollValue == 1
      return "*Fail!* "
  return ""

module.exports = (robot) ->

  robot.respond /(roll|check)\s+((\d+)\s*x)?\s*(\d+)?d(\d+)\s*((\+|-)\s*\d+)?(.*)$/i, (msg) ->

    q = {
      repeats: parseInt(msg.match[3] ? "1")
      dice: parseInt(msg.match[4] ? "1")
      sides: parseInt msg.match[5]
      modifierNum: parseInt((msg.match[6] ? "0").replace(/[\+\s]+/gi, ""))
      modifierString: (msg.match[6] ? "").replace(/\s/gi,"")
      label: (msg.match[8] ? "").trim()
    }

    if (res = rejectionResponse(q))
      msg.reply res
    else
      sets = rollSets(q.repeats, q.dice, q.sides)

      if q.label.length > 0
        q.label = " ("+q.label+")"
      if sets.length == 1
        msg.reply "#{critAlert(setTotals(sets)[0], q)}I rolled *#{setTotals(sets)[0]+q.modifierNum}*#{q.label}. [#{sets[0]}]#{q.modifierString}"
      else
        totals = setTotals(sets)
        msg.reply "I rolled#{q.label}:#{("\n"+critAlert(totals[i], q)+"*"+(totals[i]+q.modifierNum)+"* ["+sets[i].toString()+"]"+q.modifierString) for i in [0...sets.length]}"


  robot.respond /(dis)?advantage\s*((\+|-)\s*\d+)?(.*)$/i, (msg) ->
    q = {
      repeats: 2
      dice: 1
      sides: 20
      modifierNum: parseInt((msg.match[2] ? "0").replace(/[\+\s]+/gi, ""))
      modifierString: (msg.match[2] ? "").replace(/\s/gi,"")
      label: (msg.match[4] ? "").trim()
    }
    disadvantage = msg.match[1]?

    if (res = rejectionResponse(q))
      msg.reply res
    else
      sets = rollSets(q.repeats, q.dice, q.sides)
      totals = setTotals(sets)
      if (disadvantage)
        pick = minValue(totals)
      else
        pick = maxValue(totals)

      if q.label.length > 0
        q.label = " ("+q.label+")"

      msg.reply "#{critAlert(pick, q)}I rolled *#{pick+q.modifierNum}*#{q.label}. [#{sets.join(',')}]#{q.modifierString}"
