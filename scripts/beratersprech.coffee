cheerio = require('cheerio')
url = 'http://beratersprech.de/page/'
# number of available pages at beratersprech.de
maxPage = 22

module.exports = (robot) ->
  robot.hear /(berat|consult|business)/i, (msg) ->
    berater msg

berater = (msg) ->
  msg.http(getRandomPage())
    .header("User-Agent: foobar")
    .get() (err, res, body) ->
      $ = cheerio.load(body)
      domnodes = $('a[rel=bookmark]')
      domCount = domnodes.size()
      return if 0 is domCount
      randNumber = rand(domCount)
      msg.send domnodes[randNumber].text()

rand = (min, max = min) ->
  Math.round(Math.random() * (max - min - 1)) + min

getRandomPage = ->
  url + rand(1, maxPage) + '/'
