# github-org-notice

![Slack message](images/slack-message.png)

Check GitHub organization permissions and notify to Slack.

## Setup

1. Click [![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)
1. Open Heroku scheduler `ex. $ heroku addons:open scheduler --app <App Name>`
1. Add command to Heroku scheduler
   * `$ bundle exec ruby permission.rb`
