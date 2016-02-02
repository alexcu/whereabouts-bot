# Whereabouts Bot

Whereaboutsbot is a [Slack](http://slack.com) bot for responding to team members
who may be staying home (either working from home or sick), or running late. It
listens to specific Slack channel(s) and parses what users say, picking up
anything that may be related to someone in the team staying home.

Whereaboutsbot also runs an express server with an API to get and post
user's states. You can use this to integrate the bot with Slack [slash commands](https://api.slack.com/slash-commands)
or to display each of your team member's states on a dashboard such as [Dashing](http://dashing.io).

## Table of Contents

1. [States](#states)
2. [Getting Started](#getting-started)
  - [Arguments](#arguments)
3. [API](#api)
4. [Things to do](#todo)
5. [Contributing](#contributing)
6. [License](#license)

## States

The following whereabouts states are supported:

- _sick_, for when a team member is sick and not working,
- _home_, for when a team member is working from home,
- _late_, for when a team member is running late,
- _offsite_, for when a team member is working off-site, such as at another office, and
- _out_, for when a team member is currently out of the office, but will be coming back.

## Getting Started

To start the bot, install dependencies and start:

```bash
$ npm install
$ npm start
```

You can fire with a `--help` argument for extra help:

```bash
$ npm start -- --help
```

### Arguments

Specify the following arguments to Whereabouts Bot, either as a command-line argument
or as an environment variable.

#### `--slack-token` or `WHEREABOUTS_BOT_SLACK_TOKEN`
A **required** token that allows your bot to connect to Slack. This token can be
retrieved by the creator of the bot integration in the Slack admin panel.

#### `--port` or `WHEREABOUTS_BOT_PORT`
The port in which the Whereabouts API should run. Defaults to **port 3000**.

#### `--expire-time` or `WHEREABOUTS_BOT_EXPIRE_TIME`
How often the bot should clear users whereabouts state, formatted as a
[cron-formatted](https://en.wikipedia.org/wiki/Cron#Configuration_file)
time format. Defaults to **every 24 hrs at midnight**.

#### `--auth-token` or `WHEREABOUTS_BOT_AUTH_TOKEN`
Authentication token for POST requests to the API. If using a Slack slash-command
integration, use the token acquired when creating the integration.

#### `--listen-to` or `WHEREABOUTS_BOT_LISTEN_TO`
A comma-separated list of the channels the bot should listen to.

## Slack slash commands usage

When slash commands are enabled, the parameter usage is `/whereabouts [state]`,
where `state` is one of `sick`, `home`, `late`, `offsite`, `out`.

Instead of providing a state, you may also request for `help` or `clear` your
existing `whereabouts` state.

## API

### `GET /states`

Use this endpoint of retrieve the latest states of all members in your Slack team.

### `POST /state`

Use this endpoint to update the state of a specific team member. Provide a
URL-encoded body with the following parameters:

- `token` - the authentication token stipulated by `--auth-token`/`WHEREABOUTS_BOT_AUTH_TOKEN`
- `user_id` - the id of the Slack user whose state you would like to update

## TODO

Feel like contributing?

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
- Better API (json and url-encoded)
- Switch to using Redis for keeping track of states and DMs instead of just in memory
- RSS feeds of people's states
- Better `auth-token` handling?
- Add slash commands out-of-the-box
- Wrap it up into a [Slack app](https://slack.com/apps)?

# Contributing

Have an idea to extend this project or discover a bug? Feel free to contribute or raise an issue!

To extend the code base, use the following steps:

1. Fork this repo,
2. checkout a new feature or fix branch: `feature/<my-feature-name>`, `fix/<issue>` etc.,
3. commit your changes. A good guide to commit messages can be found [here](http://chris.beams.io/posts/git-commit/),
4. and create a pull request.

# License

Copyright © 2015 Alex Cummaudo. Licensed under [Apache License v2.0](http://www.apache.org/licenses/LICENSE-2.0).
