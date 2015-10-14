cheerio = require('cheerio')

module.exports = (robot) ->
  robot.hear /(sprichwort|proverb)/i, (msg) ->
    sprichwort msg

sprichwort = (msg) ->
  url = switch msg.match[0]
    when 'proverb' then 'http://proverb.gener.at/or/'
    else 'http://sprichwortrekombinator.de/'

  msg.http(url)
    .header("User-Agent: foobar")
    .get() (err, res, body) ->
      $ = cheerio.load(body)

      msg.send $('.spwort').text()
