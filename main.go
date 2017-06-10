package main

import (
	"log"
	"os"

	"github.com/mitchellh/cli"
)

func main() {
	c := cli.NewCLI("github-org-notice", "1.0.0")
	c.Args = os.Args[1:]
	c.Commands = map[string]cli.CommandFactory{
		"permission": func() (cli.Command, error) {
			return &Permission{}, nil
		},
		// "tfa": func() (cli.Command, error) {
		// 	return &Tfa{}, nil
		// },
	}

	// コマンド実行
	exitStatus, err := c.Run()
	if err != nil {
		log.Println(err)
	}

	os.Exit(exitStatus)
}
