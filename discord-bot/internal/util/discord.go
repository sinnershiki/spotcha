package util

import (
	"strings"

	"github.com/sinnershiki/spotcha/discord-bot/internal/usecase"
)

func MakeDiscordMessageWithInstanceNames(instanceNames []string) string {
	return strings.Join(instanceNames, "\n")
}

func ExistCommandName(commandName string) bool {
	return commandName == usecase.InstanceCommandName
}
