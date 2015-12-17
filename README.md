
# Whereabouts Bot

Whereaboutsbot is a [Slack](http://slack.com) bot for responding to team members who may be staying home (either working from home or sick), or running late. It listens to specific Slack channel(s) and parses what users say, picking up anything that may be related to someone in the team staying home.

Whereaboutsbot also runs a Node.js sever, with a basic API to fetch and post user's states.

The following whereabouts states are supported:

- _sick_, for when a team member is sick and not working,
- _home_, for when a team member is working from home,
- _late_, for when a team member is running late,
- _offsite_, for when a team member is working off-site, such as at another office, and
- _out_, for when a team member is currently out of the office, but will be coming back.

In addition, whereaboutsbot can also be configured as a Slack [slash command](https://api.slack.com/slash-commands) by hooking into the `POST /state/` endpoint.

## Usage

Whereabouts bot will listen for key words such as "sick", "home", "late" and so on in the channel(s) it is told to listen to. When slash commands are enabled, the parameter usage is `/whereabouts [state]`, where `state` is one of `sick`, `home`, `late`, `offsite`, `out`, `help`, or `clear`.

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
  "botToken"  : "xoxb-XXXXXXXXXXXX-TTTTTTTTTTTTTT",
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
  "authToken": "xxxxxxxx",
  "expireTime": "00 00 * * *"
}
```

- `botToken` Your auth token for the bot you have created on [Slack](https://ssil.slack.com/services/new/bot).
- `listensTo` The channels your bot listens to. Your bot should be invited to these channels by a human.
- `botResponses` Add customised bot responses to when a human talks to the bot.
- `serverPort` The port to run the server on.
- `authToken` An auth token to use for POST requests to the whereabouts bot to update state manually. This should be the same token acquired from the slash command integration (should you create one).
- `expireTime` An _optional_ [cron-formatted](https://en.wikipedia.org/wiki/Cron#Configuration_file) time format as for when people's whereabouts expire, for example at midnight (as per the example time above) to signal the start of a new day, and thus a new state for people to add their whereabouts. If left blank, then people's whereabouts will not automatically expire, and must be manually cleared using the slack command `/whereabouts clear`.

## TODO

- Add a contributing section to the README
- Allow bot to be DM'ed and ask questions and give statements like:
  - Who is working from home today?
  - Who is sick?
  - Who is out of office?
  - Where is @alex?
  - I'm staying home today
- Add timing to bot to change state of a user at a given time
  - I'll be out of office at 5pm
  - I'm going home at 4pm
  - I'll be leaving early for an appointment this afternoon
- Better API
- Switch to using Redis for keeping track of states and DMs instead of just in memory
- RSS feeds of people's states
- Better `auth-token` handling?
- Add slash commands out-of-the-box
- Wrap it up into a [Slack app](https://slack.com/apps)?
