# frozen_string_literal: true

require 'slack-notifier'

class GithubOrgTfaNotifier
  # @param webhook_url [String] Slack Incoming Webhook URL
  # @param channel [String] Slack Channel
  # @param icon_emoji [String] Slack Icon Emoji
  # @param title [String] Slack Title
  def initialize(webhook_url:, channel:, icon_emoji:, title:)
    @webhook_url = webhook_url
    @channel = channel
    @icon_emoji = icon_emoji
    @title = title
  end

  # 通知する
  #
  # @param users [Array<Sawyer::Resource>]
  def post(users)
    client.post(
      username: 'GithubOrgNotice',
      channel: channel,
      icon_emoji: icon_emoji,
      text: title,
      attachments: [
        {
          color: 'warning',
          fields: fields(users),
          footer: 'Powered by https://github.com/feedforce/github-org-notice',
        },
      ]
    )
  end

  private

  attr_reader :webhook_url, :channel, :icon_emoji, :title

  def client
    @client ||= Slack::Notifier.new(webhook_url)
  end

  def fields(users)
    users.map do |user|
      {
        title: user[:name].nil? ? user[:login] : "#{user[:login]} (#{user[:name]})",
        value: "<https://github.com/settings/security|Settings>",
        short: true,
      }
    end
  end
end
