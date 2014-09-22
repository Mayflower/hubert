module.exports = (robot) ->
  robot.respond /(fourtwenty|420)\?/, (msg) ->
    msg.http('http://its.fourtwenty.in/next').get() (err,res,body) ->
      next = JSON.parse body

      msg.reply "#{next.next420_min} minutes until it's 4:20 in #{next.city}, #{next.territory}"
