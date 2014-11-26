# Description:
#   Hubot, be polite and say hello.
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   Hello or Good Day make hubot say hello to you back
#   Good Morning makes hubot say good morning to you back
hellos = [
    "Well hello there, %",
    "Hey %, Hello!",
    "Marnin', %",
    "Good day, %",
    "Good 'aye!, %",
    "Servus %",
    "Ahoi %"
]
mornings = [
    "Good morning, %",
    "Good morning to you too, %",
    "Good day, %",
    "Good 'aye!, %"
    "Moin %"
]
module.exports = (robot) ->
    robot.hear /(hallo|sers|servus|(hello|good( [d'])?ay(e)?)|aho(i|j))/i, (msg) ->
        hello = msg.random hellos
        msg.send hello.replace "%", msg.message.user.name

    robot.hear /(^(good )?m(a|o)(rn)?in(g)?)/i, (msg) ->
        hello = msg.random mornings
        msg.send hello.replace "%", msg.message.user.name
