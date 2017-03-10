module.exports = (robot) ->

  wolfpackQuestionTimestamp = null
  wolfpackQuestioner = null

  robot.hear /\?/, (msg) ->
    msg.send "I heard you"
    msg.send msg.envelope.room
    msg.send msg.envelope.room.toLowerCase()
    if msg.envelope.room.toLowerCase() == "wolfpack"
      wolfpackQuestionTimestamp = Date.now()
      wolfpackQuestioner = msg.envelope.name

      msg.send wolfpackQuestionTimestamp
      msg.send wolfpackQuestioner

  robot.hear /^[^\?]*$/, (msg) ->
    if msg.envelope.room.toLowerCase() == "wolfpack" && msg.envelope.name != wolfpackQuestioner
      now = Date.now()
      elapsedTimeInMs = (now - wolfpackQuestionTimestamp)

      msg.send elapsedTimeInMs

      wolfpackQuestionTimestamp = null
      wolfpackWaitingForAnswer = null


      #if there's a question, record time stamp, switch to waiting mode
      #After somebody(anybody responds), capture elapsed time, switch off waiting mode, record result
