
# Whereabouts Bot

Whereaboutsbot is a [Slack](http://slack.com) bot for responding to team members who may be staying home (either working from home or sick), or running late. It listens to specific Slack channel(s) and parses what users say, picking up anything that may be related to someone in the team staying home.

Whereaboutsbot also runs a Node.js sever, with a basic API to fetch and post user's states.

In addition, whereaboutsbot can also be configured as a Slack [slash command](https://api.slack.com/slash-commands) by hooking into the `POST /state/` endpoint.

## Usage

Whereabouts bot will listen for key words such as "sick", "home", "late" and so on in the channel(s) it is told to listen to. When slash commands are enabled, the parameter usage is `/whereabouts [state]`, where `state` is one of `sick`, `home`, `late`, `offsite`, `help`, or `clear`.

Use the `GET /state/` endpoint of retrieve the latest states of team members. Use the information from this endpoint on a dashboard (e.g. [Dashing](http://dashing.io)), informing your team of who is in, who is sick and who is running late.

States expire at midnight every day automatically, ready for the next workday.

# Getting started

## Installing

1. Begin by installing Node.js on your system. You can download Node.js [here](http://nodejs.org/).
2. Install dependencies by running `npm install`
3. Start the server by running `npm start`.

## Set up config variables

Place a `config.json` under the `res` directory. Here is a sample config:

```
{
  "botToken"  : "xoxb-xxxxxxx-xxxxxxxxxxxx",
  "listensTo" : [
    "whereabouts",
    "vists",
    "events"
  ],
  "botResponses" : [
    "Go away",
    "Hey!"
  ],
  "serverPort": 3000,
  "authToken": "xxxxxxxx"
}
```

- `botToken` Your auth token for the bot you have created on [Slack](https://ssil.slack.com/services/new/bot)
- `listensTo` The channels your bot listens to. Your bot should be invited to these channels by a human.
- `botResponses` Add customised bot responses to when a human talks to the bot.
- `serverPort` The port to run the server on.
- `authToken` An auth token to use for POST requests to the whereabouts bot to update state manually. This should be the same token acquired from the slash command integration (should you create one).