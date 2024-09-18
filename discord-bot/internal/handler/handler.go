package handler

import (
	"context"
	"encoding/json"
	"fmt"
	"log/slog"
	"net/http"

	"github.com/bwmarrin/discordgo"
	"github.com/sinnershiki/spotcha/discord-bot/internal/usecase"
	"github.com/sinnershiki/spotcha/discord-bot/internal/util"
)

func Pong(ctx context.Context, w http.ResponseWriter) {
	// debug log
	slog.Debug("Handler: Pong")

	// set header
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.WriteHeader(http.StatusOK)

	// create response
	res := discordgo.InteractionResponse{
		Type: discordgo.InteractionResponsePong,
		Data: nil,
	}

	// send response
	if err := json.NewEncoder(w).Encode(res); err != nil {
		slog.Error(
			"Handler: error encoding response",
			"err", err,
		)

		w.WriteHeader(http.StatusInternalServerError)
		fmt.Fprint(w, "Internal Server Error")
	}
}

func UnknownCommand(ctx context.Context, w http.ResponseWriter) {
	// debug log
	slog.Debug("Handler: UnknownCommand")

	// set header
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.WriteHeader(http.StatusOK)

	// create response
	res := discordgo.InteractionResponse{
		Type: discordgo.InteractionResponseChannelMessageWithSource,
		Data: &discordgo.InteractionResponseData{
			Content: "unknown command",
		},
	}

	// send response
	if err := json.NewEncoder(w).Encode(res); err != nil {
		slog.Error(
			"Handler: Error encoding response",
			"err", err,
		)

		w.WriteHeader(http.StatusInternalServerError)
		fmt.Fprint(w, "Internal Server Error")
	}
}

func UnknownOption(ctx context.Context, w http.ResponseWriter) {
	// debug log
	slog.Debug("Handler: UnknownOption")

	// set header
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.WriteHeader(http.StatusOK)

	// create response
	res := discordgo.InteractionResponse{
		Type: discordgo.InteractionResponseChannelMessageWithSource,
		Data: &discordgo.InteractionResponseData{
			Content: "unknown option",
		},
	}

	// send response
	if err := json.NewEncoder(w).Encode(res); err != nil {
		slog.Error(
			"Handler: Error encoding response",
			"err", err,
		)

		w.WriteHeader(http.StatusInternalServerError)
		fmt.Fprint(w, "Internal Server Error")
	}
}

func ShowInstances(ctx context.Context, w http.ResponseWriter) {
	// debug log
	slog.Debug("Handler: ShowInstances")

	// set header
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.WriteHeader(http.StatusOK)

	// get instance names
	instanceNames, err := usecase.ShowInstances(ctx)
	if err != nil {
		slog.Error(
			"Handler: Error showing instances",
			"err", err,
		)

		w.WriteHeader(http.StatusInternalServerError)
		fmt.Fprint(w, "Internal Server Error")
		return
	}

	// create message
	instaceNmaesStr := util.MakeDiscordMessageWithInstanceNames(instanceNames)
	message := fmt.Sprintf("```%s```", instaceNmaesStr)

	// create response
	res := discordgo.InteractionResponse{
		Type: discordgo.InteractionResponseChannelMessageWithSource,
		Data: &discordgo.InteractionResponseData{
			Title:   "Instances",
			Content: message,
		},
	}

	// send response
	if err := json.NewEncoder(w).Encode(res); err != nil {
		slog.Error(
			"Handler: Error encoding response",
			"err", err,
		)

		w.WriteHeader(http.StatusInternalServerError)
		fmt.Fprint(w, "Internal Server Error")
	}
}

func StartInstance(ctx context.Context, w http.ResponseWriter, data discordgo.ApplicationCommandInteractionData) {
	// debug log
	slog.Debug("Handler: StartInstance")

	// set header
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.WriteHeader(http.StatusOK)

	// start instance
	instanceName := data.Options[0].Options[0].Value.(string)
	if err := usecase.StartInstance(ctx, instanceName); err != nil {
		slog.Error(
			"Handler: Error starting instance",
			"err", err,
		)

		w.WriteHeader(http.StatusInternalServerError)
		fmt.Fprint(w, "Internal Server Error")
		return
	}

	// create response
	res := discordgo.InteractionResponse{
		Type: discordgo.InteractionResponseChannelMessageWithSource,
		Data: &discordgo.InteractionResponseData{
			Content: "Starting instance",
		},
	}

	// send response
	if err := json.NewEncoder(w).Encode(res); err != nil {
		slog.Error(
			"Handler: Error encoding response",
			"err", err,
		)

		w.WriteHeader(http.StatusInternalServerError)
		fmt.Fprint(w, "Internal Server Error")
	}
}

func StopInstance(ctx context.Context, w http.ResponseWriter, data discordgo.ApplicationCommandInteractionData) {
	// debug log
	slog.Debug("Handler: StopInstance")

	// set header
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.WriteHeader(http.StatusOK)

	// stop instance
	instanceName := data.Options[0].Options[0].Value.(string)
	if err := usecase.StopInstance(ctx, instanceName); err != nil {
		slog.Error(
			"Handler: Error stopping instance",
			"err", err,
		)

		w.WriteHeader(http.StatusInternalServerError)
		fmt.Fprint(w, "Internal Server Error")
		return
	}

	// create response
	res := discordgo.InteractionResponse{
		Type: discordgo.InteractionResponseChannelMessageWithSource,
		Data: &discordgo.InteractionResponseData{
			Content: "Stopping instance",
		},
	}

	// send response
	if err := json.NewEncoder(w).Encode(res); err != nil {
		slog.Error(
			"Handler: Error encoding response",
			"err", err,
		)

		w.WriteHeader(http.StatusInternalServerError)
		fmt.Fprint(w, "Internal Server Error")
	}
}
