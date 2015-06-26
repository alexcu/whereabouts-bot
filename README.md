# Whereabouts Bot

1. Begin by installing Node.js on your system. You can download Node.js [here](http://nodejs.org/).
2. Install dependencies by running `npm install`
3. Start the server by running `npm start`.

# Config variables

Place a `config.json` under the `res` directory. Here is a sample config:

```
{
  "botToken"  : "xoxb-xxxxxxx-xxxxxxxxxxxx",
  "listensTo" : [
    "whereabouts",
    "vists",
    "events"
  ]
}
```

- `botToken` Your auth token for the bot you have created on [Slack](https://ssil.slack.com/services/new/bot)
- `listensTo` The channels your bot listens to. Your bot should be invited to these channels by a human.