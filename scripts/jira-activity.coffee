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
  constructor: (@url, @robot) ->
    @robot.logger.info("ActivityStream for #{@url}")
    self      = this
    self.guid = "urn:uuid:dead-beef-cafe-babe"

    @on 'guid', (guid) ->
      self.guid = guid

    @on 'activities', (activities) ->

      activities.forEach (activity) ->
        if activity.guid is self.guid
          activities.splice(activities.indexOf(activity), activities.length-activities.indexOf(activity))

      activities.reverse()
      activities.forEach (activity) ->
        sendto =
          type: 'groupchat'
          room: process.env.HUBOT_JIRA_STREAM_ROOM

        self.robot.send sendto, "#{activity.title} <#{activity.link}>#{activity.description()}\n"

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
  parser = new FeedParser
  stream = new ActivityStream process.env.HUBOT_JIRA_STREAM_URL,
                              @robot

  parser.on 'end', (articles) ->
    stream.parse articles
    parser._reset

  run = (stream, parser) ->
    parser.parseUrl(stream.url)

  setInterval (-> run stream, parser), 30000
