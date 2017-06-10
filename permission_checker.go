package main

import (
	"fmt"
	"strings"
	"time"

	"github.com/octokit/go-octokit/octokit"
)

// PermissionCheckerParams is for parameters of permission sub command
type PermissionCheckerParams struct {
	orgName         string
	accessToken     string
	teamsPermission string
	skipDays        string
}

// PermissionChecker is for permission sub command
type PermissionChecker struct {
	PermissionCheckerParams
}

// NewPermissionChecker returns new PermissionChecker struct
func NewPermissionChecker(pp PermissionCheckerParams) PermissionChecker {
	p := PermissionChecker{PermissionCheckerParams: pp}
	return p
}

// Execute PermissionChecker
func (p *PermissionChecker) Execute() error {
	fmt.Println("orgName:", p.orgName)
	fmt.Println("accessToken:", p.accessToken)
	fmt.Println("teamsPermission:", p.teamsPermission)
	fmt.Println("skipDays:", p.skipDays)

	if skip(p.skipDays) {
		fmt.Printf("This is skipped for skip_days (%s).\n", p.skipDays)
		return nil
	}

	fmt.Println("Started PermissionChecker.Execute")

	client := getClient(p.accessToken)

	repos, err := getRepos(client, p.orgName)
	if err != nil {
		return err
	}

	for _, repo := range repos {
		// Octokit::Client::Repositories#repository_teams に相当する関数がないので諦めた。
		// teams, _ := client.Organization().GetTeams(nil, octokit.M{"org": p.orgName})

		// fmt.Println(teams)

		if isValidPermission(repo.Permissions) {
			fmt.Printf("Checking %s OK. Admin=%t, Push=%t, Pull=%t\n", repo.FullName, repo.Permissions.Admin, repo.Permissions.Push, repo.Permissions.Pull)
			// fmt.Printf("Checking %s OK.\n", repo.FullName)
		} else {
			fmt.Printf("Checking %s NG.\n", repo.FullName)
		}
	}

	return nil
}

func skip(skipDays string) bool {
	if skipDays == "" {
		return false
	}

	// See https://golang.org/pkg/time/#pkg-constants
	today := time.Now().Format("Mon")

	for _, day := range strings.Split(skipDays, ",") {
		if day == today {
			return true
		}
	}

	return false
}

func getRepos(client *octokit.Client, orgName string) ([]octokit.Repository, error) {
	result := []octokit.Repository{}

	repos, resp := client.Organization().OrganizationRepos(nil, octokit.M{"org": orgName})

	for {
		if resp.HasError() {
			return nil, resp.Err
		}

		result = append(result, repos...)

		if resp.NextPage == nil {
			break
		}

		repos, resp = client.Organization().OrganizationRepos(resp.NextPage, nil)
	}

	return result, nil
}

func isValidPermission(_ octokit.Permissions) bool {
	return true
}

func getClient(accessToken string) *octokit.Client {
	return octokit.NewClient(
		&octokit.TokenAuth{AccessToken: accessToken},
	)
}
