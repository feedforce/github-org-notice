# frozen_string_literal: true

require 'octokit'

class GithubOrgPermissionChecker
  # @param org_name [String] GitHub Organization
  # @param access_token [String] GitHub Access Token
  # @param teams_permission [String] Teams permission
  # @param skip_days [String] Skip days for checking
  # @param notifier [#post] the notifier object to post
  def initialize(org_name:, access_token:, teams_permission:, skip_days:, notifier:)
    @org_name = org_name
    @access_token = access_token
    @raw_teams_permission = teams_permission
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

    result_repos = []

    repos.each do |repo|
      begin
        teams = client.repository_teams(repo[:full_name])
      rescue Octokit::NotFound
        # なぜか #repos が削除したリポジトリを返したため
        puts "Not Found #{repo[:full_name]}"
        next
      end

      if valid_permission?(repo, teams)
        puts "Checking #{repo[:full_name]} OK."
      else
        puts "Checking #{repo[:full_name]} NG."
        result_repos << repo
      end
    end

    notifier.post(result_repos) unless result_repos.empty?

    puts "`result_repos` number is #{result_repos.count}."
    puts "Completed #{self.class.name}##{__method__}"
  end

  private

  attr_reader :org_name, :access_token, :raw_teams_permission, :skip_days, :notifier

  def skip?
    skip_days &&
      skip_days.split(',').include?(Time.now.strftime('%a'))
  end

  def repos
    repos = client.organization_repositories(org_name)
    last_response = client.last_response

    while last_response.rels[:next]
      last_response = last_response.rels[:next].get
      repos.concat(last_response.data)
    end

    repos
  end

  def valid_permission?(repo, teams)
    teams_permission.each do |name, permission|
      unless have_permission?(teams, name: name, permission: permission)
        return false
      end
    end

    collaborators(repo).empty?
  end

  # PowerUsers=admin,Users=push
  # ↓
  # {"PowerUsers"=>"admin", "Users"=>"push"}
  #
  # @return [Hash]
  def teams_permission
    @teams_permission ||=
      begin
        ary = (raw_teams_permission || "")
                .split(',')
                .map{|e| e.split('=')}
                .flatten
        Hash[*ary]
      end
  end

  def have_permission?(teams, name:, permission:)
    teams.find_index {|team| team[:name] == name && team[:permission] == permission}
  end

  def collaborators(repo)
    client.collaborators(repo[:full_name], affiliation: 'outside')
  end

  def client
    @client ||= Octokit::Client.new(access_token: access_token)
  end
end
