cheerio = require('cheerio')

module.exports = (robot) ->
  robot.hear /sprichwort/i, (msg) ->
    msg.http("http://sprichwortrekombinator.de/")
      .header("User-Agent: foobar")
      .get() (err, res, body) ->
        msg.send sprichwort(body)

sprichwort = (body) ->
  $ = cheerio.load(body)
  $('.spwort').text()
