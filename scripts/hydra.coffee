# Description:
#   Post hydra related events using the slack hook
#
# Configuration:
#   HYDRA_CHANNEL
#
# URLS:
#   /hydra/webhook
#
# Author:
#   globin

module.exports = (robot) ->
  room = process.env.HYDRA_CHANNEL or 'opensource@conference.mayflower.de'
  debug = process.env.GITLAB_DEBUG?

  robot.router.post '/hydra/webhook', (req, res) ->
    data = req.body
    text = data.attachments[0].text

    robot.send({
      type: 'groupchat',
      room: room
    }, text)

    res.writeHead(204)
    res.end()
