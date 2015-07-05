# Description:
#   Send JIRA Activity Stream to a room.
#
# Dependencies:
#   ent, feedparser
#
# Configuration:
#   HUBOT_JIRA_STREAM_ROOM
#   HUBOT_JIRA_STREAM_URL

FeedParser      = require('feedparser')
ent             = require('ent')
{EventEmitter}  = require('events')

class ActivityStream extends EventEmitter
  constructor: (@url, @robot, @room) ->
    @robot.logger.info("ActivityStream from #{@url} to #{@room}")
    self = this

    @robot.brain.on 'loaded', =>
      self.guid = @robot.brain.data.jira_activity[@room]

    @on 'guid', (guid) ->
      self.guid = guid
      @robot.brain.data.jira_activity[@room] = guid

    @on 'activities', (activities) =>
      activities.forEach (activity) ->
        if activity.guid is self.guid
          activities.splice(activities.indexOf(activity), activities.length - activities.indexOf(activity))

      activities.reverse()
      activities.forEach (activity) =>
        sendto =
          type: 'groupchat'
          room: @room

        @robot.send sendto, "#{activity.title} <#{activity.link}>#{activity.description()}\n"

        if activities.indexOf(activity) is activities.length-1
          self.emit 'guid', activity.guid

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

module.exports = (@robot) ->
  # Internal: Initialize our brain
  @robot.brain.on 'loaded', =>
    @robot.brain.data.jira_activity ||= {}

  streamHandlers = process.env.HUBOT_JIRA_STREAM_URL.split(',').map((url_room_data) ->
    [url, room] = url_room_data.split('->')
    stream = new ActivityStream(url, @robot, room)
    parser = new FeedParser
    parser.on 'end', (articles) ->
      stream.parse articles
      parser._reset

    return {
      stream: stream
      parser: parser
    }
  )

  run = (stream, parser) ->
    @robot.logger.info("Running for #{stream.url}")
    parser.parseUrl(stream.url)

  streamHandlers.forEach((streamHandler) ->
    setInterval((-> run streamHandler.stream, streamHandler.parser), 10 * 1000)
  )
