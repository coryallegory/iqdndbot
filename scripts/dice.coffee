# Description:
#   Have Hubot roll dice with optional modifier.
#   Case and whitespace insensitive.
#   An extension of hubot-scripts/dice.coffee
#
#   > roll d6
#   5  [rolls: 5]
#
#   > roll 2d6
#   6  [rolls: 4,2]
#
#   > roll 2x 3d6 + 2 for luck
#   11 for luck [rolls: 4,2,3]
#   17 for luck [rolls: 6,6,3]
#
#   > roll advantage
#   19  [rolls: 2,19]
#
#   > roll disadvantage +8 for hit check
#   10 for hit check [rolls: 10,17]
#
# Dependencies:
#   mathjs
#
# Configuration:
#   None
#
# Commands:
#   roll [#x] #d# [+|-#d# +|-# ...] [label]- optional #x will repeat the command, can concatenate any number of dice rolls and arithmetic modifiers.
#   roll [#x] (advantage|disadvantage) [+|- #] - optional #x will repeat the command, rolls d20 twice and applies optional modifier. Advantage takes greater value, disadvantage takes lesser value.
#   
# Author:
#   coryallegory
#

math = require('mathjs')


# return int, roll value
roll = (sides) ->
  1 + Math.floor(Math.random() * sides)

# return int[], roll values
rollMultiple = (numdice, sides) ->
  roll(sides) for i in [0...numdice]

sum = (array) ->
  array.reduce (x, y) -> x + y

deepSum = (array) ->
  sum array.map(sum)


module.exports = (robot) ->

  robot.hear /roll ((\d*) ?x ?)?(\d*)d(\d+)(( ?(\+|-) ?\d*(d\d+)?)*) ?(.*)$/i, (msg) ->
    repeats = parseInt(msg.match[2] || "1")
    numdice = parseInt(msg.match[3] || "1")
    sides = parseInt msg.match[4]
    extras = msg.match[5] || ""
    label = (msg.match[..].pop() || "").trim()

    if repeats < 1
      msg.reply "I don't know how to roll less than one set of rolls."
      return
    if repeats > 100
      msg.reply "I'm not going to roll more than 100 sets of rolls."
      return
    if sides < 1
      msg.reply "I don't know how to roll a zero-sided die."
      return
    if numdice > 50
      msg.reply "I'm not going to roll more than 50 dice for you."
      return

    for [0...repeats]
      rolls = []
      rolls.push rollMultiple(numdice, sides)

      critString = ""
      if numdice == 1
        if rolls[0][0] == 1 then critString = "*Fail!* "
        else if rolls[0][0] == 20 then critString = "*Crit!* "

      extraTotal = 0
      matches = (extras.match /(\+|-) ?\d*(d\d+)?/gi) || []
      for extra, i in matches
        parts = extra.trim().match /(\+|-) ?(\d*)(d(\d+))?$/i
        operator = parts[1]
        n = parseInt(parts[2])
        s = parseInt(parts[4])
        if isNaN(s)
          extraTotal += math.eval(operator + n)
        else
          critString = ""
          if n > 50
            msg.reply "I'm not going to roll more than 50 dice for you."
            return
          if s < 1
            msg.reply "I don't know how to roll a zero-sided die."
            return
          rolls.push rollMultiple(n, s)

      total = extraTotal + deepSum(rolls)

      msg.reply critString + "*#{total}* _#{label} (rolls: [#{rolls.join("],[")}])_"

  robot.hear /roll ((\d+) ?x ?)?(dis)?advantage\s*(((\+|-)\s*\d+\s*)*)(.*)$/i, (msg) ->
    repeats = parseInt(msg.match[2] || "1")
    disadvantage = msg.match[3]?
    modifier = math.eval(msg.match[4] || "0")
    label = (msg.match[..].pop() || "").trim()

    for [0...repeats]
      r1 = roll(20)
      r2 = roll(20)

      critString = ""
      if (disadvantage)
        pick = Math.min(r1, r2)
        if pick == 1 then critString = "*Fail!* "
      else
        pick = Math.max(r1, r2)
        if pick == 20 then critString = "*Crit!* "
      pick += modifier

      msg.reply critString + "*#{pick}* _#{label} (rolls: #{r1},#{r2})_"
