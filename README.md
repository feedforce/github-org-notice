# github-org-notice

Check the following of GitHub organization and notify to Slack.

* Repository permissions

    ![Slack message of permission checker](images/slack-message-permission.png)

* 2FA disabled users

    ![Slack message of 2FA checker](images/slack-message-2fa.png)

## Setup

1. Click [![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)
1. Open Heroku scheduler `ex. $ heroku addons:open scheduler --app <App Name>`
1. Add command to Heroku scheduler
   * `$ bundle exec ruby permission.rb`
   * `$ bundle exec ruby tfa.rb`
