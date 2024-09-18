package bot

import (
	"context"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io"
	"log/slog"
	"net/http"
	"os"

	"github.com/GoogleCloudPlatform/functions-framework-go/functions"
	"github.com/bwmarrin/discordgo"
	"github.com/sinnershiki/spotcha/discord-bot/internal/handler"
	"github.com/sinnershiki/spotcha/discord-bot/internal/util"
)

var logLevel *slog.LevelVar

func init() {
	logLevel = new(slog.LevelVar)
	ops := slog.HandlerOptions{
		Level: logLevel,
	}

	logger := slog.New(slog.NewJSONHandler(os.Stdout, &ops))
	slog.SetDefault(logger)

	// set log level debug
	if slog.LevelDebug.String() == os.Getenv("LOG_LEVEL") {
		logLevel.Set(slog.LevelDebug)
		slog.Debug("Log level set to debug")
	}

	functions.HTTP("DiscordBot", DiscordBot)
}

func DiscordBot(w http.ResponseWriter, r *http.Request) {
	ctx := context.Background()

	// verify request
	if !verifyInteraction(w, r) {
		return
	}

	defer r.Body.Close()
	var interaction discordgo.Interaction
	body, _ := io.ReadAll(r.Body)
	if err := json.Unmarshal(body, &interaction); err != nil {
		slog.Error(
			"Error unmarshaling body",
			"err", err,
		)

		w.WriteHeader(http.StatusInternalServerError)
		fmt.Fprint(w, "Internal Server Error")
		return
	}

	// access log
	slog.Info(
		"Access Log",
		"method", r.Method,
		"url", r.URL.String(),
		"remote_addr", r.RemoteAddr,
		"user_agent", r.UserAgent(),
		"header", r.Header,
		"host", r.Host,
		"body", string(body),
	)

	// slash commands
	data := interaction.ApplicationCommandData()

	// handle commands
	// pong
	if interaction.Type == discordgo.InteractionPing {
		handler.Pong(ctx, w)
		return
	}

	// unknown command
	if !util.ExistCommandName(data.Name) {
		handler.UnknownCommand(ctx, w)
		return
	}

	// handle instance command
	if data.Name == "instance" {
		slog.Info(
			"instance command",
			"data", data.Name,
			"options", data.Options,
		)

		option := data.Options[0].Name
		switch option {
		case "show":
			// show instances
			handler.ShowInstances(ctx, w)
			return
		case "start", "up":
			// start instance
			handler.StartInstance(ctx, w, data)
		case "stop", "down":
			// stop instance
			handler.StopInstance(ctx, w, data)
		default:
			// unknown option
			handler.UnknownOption(ctx, w)
		}
	}
}

func verifyInteraction(w http.ResponseWriter, r *http.Request) bool {
	pubkey, err := hex.DecodeString(os.Getenv("DISCORD_PUBLIC_KEY"))
	if err != nil {
		slog.Error(
			"Error decoding public key",
			"err", err,
		)

		w.WriteHeader(http.StatusInternalServerError)
		fmt.Fprint(w, "Internal Server Error due to decording public key")
		return false
	}

	if !discordgo.VerifyInteraction(r, pubkey) {
		slog.Info(
			"Unauthorized request",
			"err", err,
		)

		w.WriteHeader(http.StatusUnauthorized)
		fmt.Fprint(w, "Unauthorized")
		return false
	}

	return true
}
