# frozen_string_literal: true

require 'octokit'

class GithubOrgTfaChecker
  # @param org_name [String] GitHub Organization
  # @param access_token [String] GitHub Access Token
  # @param ignore_users [String] Ignore accounts for checking
  # @param skip_days [String] Skip days for checking
  # @param notifier [#post] the notifier object to post
  def initialize(org_name:, access_token:, ignore_users:, skip_days:, notifier:)
    @org_name = org_name
    @access_token = access_token
    @raw_ignore_users = ignore_users
    @skip_days = skip_days
    @notifier = notifier
  end

  # 権限の設定が必要なリポジトリを通知する
  def execute
    if skip?
      puts "This is skipped for skip_days (#{skip_days})."
      return
    end

    puts "Started #{self.class.name}##{__method__}"

    result_users = []

    tfa_disabled_users.each do |user|
      if ignore_user?(user)
        puts "Ignore #{user[:login]}"
      else
        puts "Checking #{user[:login]} NG."
        result_users << user
      end
    end

    notifier.post(result_users) unless result_users.empty?

    puts "`result_users` number is #{result_users.count}."
    puts "Completed #{self.class.name}##{__method__}"
  end

  private

  attr_reader :org_name, :access_token, :raw_ignore_users, :skip_days, :notifier

  def skip?
    skip_days &&
      skip_days.split(',').include?(Time.now.strftime('%a'))
  end

  # 二段階認証を設定していないユーザを返す
  #
  # @return [Array<Sawyer::Resource>]
  def tfa_disabled_users
    users = client.organization_members(org_name, filter: '2fa_disabled')
    last_response = client.last_response

    while last_response.rels[:next]
      last_response = last_response.rels[:next].get
      users.concat(last_response.data)
    end

    # user[:name] が欲しい。
    users.map {|user| client.user(user[:login])}
  end

  # 無視するユーザかを返す
  #
  # @param user [Sawyer::Resource]
  # @return [Boolean]
  def ignore_user?(user)
    ignore_users.include?(user[:login])
  end

  # user1,user2
  # ↓
  # ["user1", "user2"]
  #
  # @return [Array<String>]
  def ignore_users
    @ignore_users ||= raw_ignore_users.split(',')
  end

  def client
    @client ||= Octokit::Client.new(access_token: access_token)
  end
end
