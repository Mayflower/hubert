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
#  join [room] - Join room
#  leave [room] - Leave room
_ = require 'underscore'

module.exports = (robot) ->
  join = (room) ->
    robot.logger.info("Joining #{room}")
    robot.brain.data.rooms.push room

    _room =
      jid: room

    robot.adapter.joinRoom _room

  leave = (room) ->
    robot.logger.info("Leaving #{room}")
    robot.brain.data.rooms = robot.brain.data.rooms.filter (it) -> it isnt room

    _room =
      jid: room

    robot.adapter.leaveRoom _room

  robot.brain.on 'loaded', =>
    robot.brain.data.rooms ||= []
    robot.brain.data.rooms = _.union(robot.brain.data.rooms, process.env.HUBOT_XMPP_ROOMS.split(','))

    for room in robot.brain.data.rooms
      join room

  robot.respond /join ([^@]+)@?([^@]+)?/i, (msg) ->
    room = msg.match[1]
    domain = msg.match[2] || msg.message.user.room.split('@')[1]
    join "#{room}@#{domain}"

  robot.respond /leave ?([^ ]*)?/i, (msg) ->
    room = msg.match[1] || msg.message.user.room
    leave room
