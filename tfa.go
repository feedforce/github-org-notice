package main

import (
	"log"
)

/** tfa サブコマンド用の実装 **/
type Tfa struct{}

func (b *Tfa) Help() string {
	return "app tfa"
}

func (b *Tfa) Run(args []string) int {
	log.Println("Tfa!")
	return 0
}

func (b *Tfa) Synopsis() string {
	return "Print \"Tfa!\""
}
