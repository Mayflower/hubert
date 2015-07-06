# Description:
#   Send JIRA Activity Stream to a room.
#
# Dependencies:
#   ent, feedparser
#
# Configuration:
#   HUBOT_JIRA_URL
#   HUBOT_JIRA_USER
#   HUBOT_JIRA_PASSWORD
#
# Commands:
#   hubot jira watch <KEY> - Start watching events project
#   hubot jira stop watching <KEY> - Stop watching events for the project
#   hubot jira watching - Show what you're watching
#

FeedParser      = require('feedparser')
ent             = require('ent')
{EventEmitter}  = require('events')

class ActivityStream extends EventEmitter
  constructor: (@url, @robot, @room) ->
    @robot.logger.info("ActivityStream from #{@url} to #{@room}")

    @on 'activities', (activities) =>
      activities.forEach (activity) =>

        if activity.guid is @robot.brain.data.jira_activity.guid[@room]
          activities.splice(activities.indexOf(activity), activities.length - activities.indexOf(activity))

      activities.reverse()
      activities.forEach (activity) =>
        sendto =
          type: 'groupchat'
          room: @room

        @robot.send sendto, "#{activity.title} <#{activity.link}>#{activity.description()}\n"

        if activities.indexOf(activity) is activities.length-1
          @robot.brain.data.jira_activity.guid[@room] = activity.guid

  parse: (articles) ->
    activities = []
    articles.forEach (article) ->
      activity =
        title: ent.decode(article.title.replace(/<(?:.|\n)*?>/gm, '').replace(/\ \ \ /, ' '))
        description: ->
          if article.description != null
            "\n" + ent.decode(article.description.replace(/<(?:.|\n)*?>/gm, '').replace(/\ \ \ /, ' '))
          else
            ""
        link: article.link
        guid: article.guid

      activities.push activity

    @emit 'activities', activities


build_url = (keys) ->
  url = process.env.HUBOT_JIRA_URL.split('://')[1]
  user = process.env.HUBOT_JIRA_USER
  password = process.env.HUBOT_JIRA_PASSWORD
  query = keys.map((key) -> "key+IS+#{key}").join("+OR+")

  "https://#{user}:#{password}@#{url}/activity?maxResults=10&os_authType=basic&streams=#{query}"


buildHandler = (room, keys) ->
  url = build_url(keys)
  stream = new ActivityStream(url, @robot, room)
  parser = new FeedParser
  parser.on 'end', (articles) ->
    stream.parse articles
    parser._reset

  {
    stream: stream
    parser: parser
    room: room
  }


module.exports = (@robot) ->
  timeouts = {}

  run = (handler) ->
    {stream, parser, room} = handler
    parser.parseUrl(stream.url)
    timeouts[room] = setTimeout((() -> run(handler)), 10 * 1000)

  @robot.respond /jira watch ([A-Z0-9]+)/, (msg) ->
    key = msg.match[1]
    room = msg.message.user.room
    currentKeys = @robot.brain.data.jira_activity.subscription[room] || []
    sendto =
      type: 'groupchat'
      room: room

    if key in currentKeys
      @robot.send(sendto, "I am already watching #{key} in #{room}")
    else
      clearTimeout(timeouts[room])
      keys = currentKeys.concat(key)
      run(buildHandler(room, keys))
      @robot.brain.data.jira_activity.subscription[room] = keys
      @robot.send(sendto, "I've started watching #{key} in #{room}")

  @robot.respond /jira stop watching ([A-Z0-9]+)/, (msg) ->
    key = msg.match[1]
    room = msg.message.user.room
    currentKeys = @robot.brain.data.jira_activity.subscription[room]
    sendto =
      type: 'groupchat'
      room: room

    if key not in currentKeys
      @robot.send(sendto, "I am currently not watching #{key} in #{room}")
    else
      clearTimeout(timeouts[room])
      keys = currentKeys.filter((k) -> k != key)
      run(buildHandler(room, keys))
      @robot.brain.data.jira_activity.subscription[room] = keys
      @robot.send(sendto, "I've stopped watching #{key} in #{room}")

  @robot.respond /jira watching/, (msg) ->
    room = msg.message.user.room
    currentKeys = @robot.brain.data.jira_activity.subscription[room]
    sendto =
      type: 'groupchat'
      room: room
    @robot.send(sendto, "I am currently watching #{currentKeys.join(', ') || nothing} in #{room}")

  @robot.brain.on 'loaded', =>
    # Internal: Initialize our brain
    @robot.brain.data.jira_activity ||= {}
    @robot.brain.data.jira_activity.guid ||= {}
    @robot.brain.data.jira_activity.subscription ||= {}

    Object.keys(@robot.brain.data.jira_activity.subscription).forEach((room) ->
      keys = @robot.brain.data.jira_activity.subscription[room]
      run(buildHandler(room, keys))
    )
