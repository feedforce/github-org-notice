package main

import (
	"os"
)

/** permission サブコマンド用の実装 **/
type Permission struct{}

func (f *Permission) Help() string {
	return "app permission"
}

func (f *Permission) Run(args []string) int {
	p := NewPermissionChecker(
		PermissionCheckerParams{
			orgName:         os.Getenv("GITHUB_ORGANIZATION"),
			accessToken:     os.Getenv("GITHUB_ACCESS_TOKEN"),
			teamsPermission: os.Getenv("TEAMS_PERMISSION"),
			skipDays:        os.Getenv("SKIP_DAYS"),
		},
	)
	p.Execute()
	return 0
}

func (f *Permission) Synopsis() string {
	return "Print \"Permission!\""
}
