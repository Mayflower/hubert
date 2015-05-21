# Description:
#   Time to 420
#
# Dependencies:
#   None
#
# Commands:
#   hubot 420 - Sends a message to all hubot rooms.

module.exports = (robot) ->
  robot.respond /(fourtwenty|420)\?/, (msg) ->
    msg.http('http://its.fourtwenty.in/next').get() (err,res,body) ->
      next = JSON.parse body

      msg.reply "#{next.next420_min} minutes until it's 4:20 in #{next.city}, #{next.territory}"

      if next.next420_min >= 5
        setTimeout ->
          msg.reply "5 minutes until it's 4:20 in #{next.city}, #{next.territory}"
        , (next.next420_min-5)*60000
      else
        msg.reply "You better hurry!"
