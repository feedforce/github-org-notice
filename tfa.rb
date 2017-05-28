# frozen_string_literal: true

require_relative 'lib/github_org_tfa_checker'
require_relative 'lib/github_org_tfa_notifier'

notifier = GithubOrgTfaNotifier.new(
  webhook_url: ENV['SLACK_WEBHOOK_URL'],
  channel:     ENV['SLACK_CHANNEL_FOR_TFA'],
  icon_emoji:  ENV['SLACK_ICON_EMOJI'],
  title:       ENV['SLACK_TITLE_FOR_TFA']
)

GithubOrgTfaChecker.new(
  org_name:        ENV['GITHUB_ORGANIZATION'],
  access_token:    ENV['GITHUB_ACCESS_TOKEN'],
  ignore_users:    ENV['IGNORE_USERS'],
  skip_days:       ENV['SKIP_DAYS'],
  notifier:        notifier
).execute
