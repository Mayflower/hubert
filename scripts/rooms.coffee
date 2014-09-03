# Description:
#   Manage rooms with Hubot's brain.
#
# Dependencies:
#  hubot-xmpp
#
# Configuration:
#  None
#
# Commands:
#  join <room> - Join room
#  leave [room] - Leave room
_ = require 'underscore'

module.exports = (robot) ->
  join = (room) ->
    robot.logger.info("Joining #{room}")

    _room =
      jid: room

    robot.adapter.joinRoom _room

  leave = (room) ->
    robot.logger.info("Leaving #{room}")

    _room =
      jid: room

    robot.adapter.leaveRoom _room

  robot.brain.on 'loaded', =>
    robot.brain.data.rooms ||= []
    robot.brain.data.rooms = _.union(robot.brain.data.rooms, process.env.HUBOT_XMPP_ROOMS.split(','))

    for room in robot.brain.data.rooms
      join room

  robot.respond /join ([^ ]*)/i, (msg) ->
    room = msg.match[1]
    robot.brain.data.rooms.push room
    join room

  robot.respond /leave ?([^ ]*)?/i, (msg) ->
    room = msg.match[1] || msg.message.user.room
    for _room, i in robot.brain.data.rooms
      if _room == room
        robot.brain.data.rooms = robot.brain.data.rooms.slice i, 1
    leave room
