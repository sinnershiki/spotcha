package usecase

import (
	"context"
	"log/slog"

	computeEngine "github.com/sinnershiki/spotcha/discord-bot/internal/infra/compute_engine"
)

const (
	InstanceCommandName = "instance"
)

func ShowInstances(ctx context.Context) ([]string, error) {
	computeEngineCli, err := computeEngine.NewRESTClient(ctx)
	if err != nil {
		slog.Error(
			"Error creating compute engine client",
			"err", err,
		)

		return nil, err
	}
	defer computeEngineCli.Close()

	instanceNames, err := computeEngineCli.GetAggregateInstanceNames(ctx)
	if err != nil {
		slog.Error(
			"Error getting instance names",
			"err", err,
		)
		return nil, err
	}

	return instanceNames, nil
}

func StartInstance(ctx context.Context, instanceName string) error {
	computeEngineCli, err := computeEngine.NewRESTClient(ctx)
	if err != nil {
		slog.Error(
			"Error creating compute engine client",
			"err", err,
		)

		return err
	}
	defer computeEngineCli.Close()

	if err := computeEngineCli.StartInstanceNoWait(ctx, instanceName); err != nil {
		slog.Error(
			"Error starting instance",
			"err", err,
		)
		return err
	}

	return nil
}

func StopInstance(ctx context.Context, instanceName string) error {
	computeEngineCli, err := computeEngine.NewRESTClient(ctx)
	if err != nil {
		slog.Error(
			"Error creating compute engine client",
			"err", err,
		)

		return err
	}
	defer computeEngineCli.Close()

	if err := computeEngineCli.StopInstanceNoWait(ctx, instanceName); err != nil {
		slog.Error(
			"Error stopping instance",
			"err", err,
		)

		return err
	}

	return nil
}
