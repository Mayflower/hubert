cheerio = require('cheerio')

module.exports = (robot) ->
  robot.hear /sprichw*/i, (msg) ->
    sprichwort 'http://sprichwortrekombinator.de/', msg

  robot.hear /proverb/i, (msg) ->
    sprichwort 'http://proverb.gener.at/or/', msg

sprichwort = (url, msg) ->
  msg.http(url)
    .header("User-Agent: foobar")
    .get() (err, res, body) ->
      $ = cheerio.load(body)
      msg.send $('.spwort').text()
