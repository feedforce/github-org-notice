# frozen_string_literal: true

require_relative 'lib/github_org_permission_checker'
require_relative 'lib/github_org_permission_notifier'

notifier = GithubOrgPermissionNotifier.new(
  webhook_url: ENV['SLACK_WEBHOOK_URL'],
  channel:     ENV['SLACK_CHANNEL_FOR_PERMISSION'],
  icon_emoji:  ENV['SLACK_ICON_EMOJI'],
  title:       ENV['SLACK_TITLE_FOR_PERMISSION']
)

GithubOrgPermissionChecker.new(
  org_name:         ENV['GITHUB_ORGANIZATION'],
  access_token:     ENV['GITHUB_ACCESS_TOKEN'],
  teams_permission: ENV['TEAMS_PERMISSION'],
  skip_days:        ENV['SKIP_DAYS'],
  notifier:         notifier
).execute
