package main

import (
	"context"
	"log/slog"
	"os"

	computeEngine "github.com/sinnershiki/spotcha/discord-bot/internal/infra/compute_engine"
)

func init() {
	logLevel := new(slog.LevelVar)
	ops := slog.HandlerOptions{
		Level: logLevel,
	}

	logger := slog.New(slog.NewJSONHandler(os.Stdout, &ops))
	slog.SetDefault(logger)

	// set log level debug
	logLevel.Set(slog.LevelDebug)
	slog.Debug("Log level set to debug")
}

func main() {
	ctx := context.Background()
	computeEngineCli, err := computeEngine.NewRESTClient(ctx)
	if err != nil {
		slog.Error(
			"Error creating compute engine client",
			"err", err,
		)

		return
	}
	defer computeEngineCli.Close()

	instanceNames, err := computeEngineCli.GetAggregateInstanceNames(ctx)
	if err != nil {
		slog.Error(
			"Error getting instance names",
			"err", err,
		)
		return
	}

	slog.Info(
		"Instance names",
		"instance_names", instanceNames,
	)
}
