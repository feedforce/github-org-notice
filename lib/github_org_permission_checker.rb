# frozen_string_literal: true

require 'octokit'

class GithubOrgPermissionChecker
  # @param org_name [String] GitHub Organization
  # @param access_token [String] GitHub Access Token
  # @param notifier_name [#post] the notifier object to post
  def initialize(org_name:, access_token:, notifier:)
    @org_name = org_name
    @access_token = access_token
    @notifier = notifier
  end

  # 権限の設定が必要なリポジトリを通知する
  #
  # @see https://goo.gl/7DjYTu
  def execute
    puts 'Started GithubOrgPermissionChecker#execute'

    result_repos = []

    repos.each do |repo|
      teams = client.repository_teams(repo[:full_name])

      if valid_permission?(repo, teams)
        puts "Checking #{repo[:full_name]} OK."
        next
      else
        puts "Checking #{repo[:full_name]} NG."
      end

      result_repos << repo
    end

    notifier.post(result_repos) unless result_repos.empty?

    puts "`result_repos` number is #{result_repos.count}."
    puts 'Completed GithubOrgPermissionChecker#execute'
  end

  private

  attr_reader :org_name, :access_token, :notifier

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
    if ! have_permission?(teams, name: 'PowerUsers', permission: 'admin')
      return false
    end

    if ! have_permission?(teams, name: 'Users', permission: 'push')
      return false
    end

    collaborators(repo).empty?
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
