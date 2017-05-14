# frozen_string_literal: true

require 'slack-notifier'

class GithubOrgPermissionNotifier
  # @param webhook_url [String] Slack Incoming Webhook URL
  # @param channel [String] Slack Channel
  def initialize(webhook_url:, channel:)
    @webhook_url = webhook_url
    @channel = channel
  end

  # 通知する
  #
  # @param repos [Array<Sawyer::Resource>]
  def post(repos)
    client.post(
      username: 'GithubOrgPermissionChecker',
      channel: channel,
      icon_emoji: ':github:',
      text: '@github-owners https://goo.gl/7DjYTu を参考にして、権限の設定をお願いします。',
      attachments: [
        {
          color: 'warning',
          fields: fields(repos),
          footer: 'Powered by https://dashboard.heroku.com/apps/github-org-permission-checker',
        },
      ]
    )
  end

  private

  attr_reader :webhook_url, :channel

  def client
    @client ||= Slack::Notifier.new(webhook_url)
  end

  def fields(repos)
    repos.map do |repo|
      {
        title: repo[:full_name],
        value: "<https://github.com/#{repo[:full_name]}/settings/collaboration|Settings>",
        short: true,
      }
    end
  end
end
