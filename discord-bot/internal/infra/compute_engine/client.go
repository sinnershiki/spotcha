package computeengine

import (
	"context"

	compute "cloud.google.com/go/compute/apiv1"
	"github.com/sinnershiki/spotcha/discord-bot/internal/config"
	"google.golang.org/api/iterator"
	computepb "google.golang.org/genproto/googleapis/cloud/compute/v1"
)

type ComputeEngineClient struct {
	computeEngineClient *compute.InstancesClient
}

func NewRESTClient(ctx context.Context) (*ComputeEngineClient, error) {
	computeEngineClient, err := compute.NewInstancesRESTClient(ctx)
	if err != nil {
		return nil, err
	}

	return &ComputeEngineClient{
		computeEngineClient: computeEngineClient,
	}, nil
}

func (c *ComputeEngineClient) Close() {
	c.computeEngineClient.Close()
}

func (c *ComputeEngineClient) GetAggregateInstanceNames(ctx context.Context) ([]string, error) {
	var instanceNames []string
	req := &computepb.AggregatedListInstancesRequest{
		Project: config.GetProjectID(),
	}

	it := c.computeEngineClient.AggregatedList(ctx, req)
	for {
		pair, err := it.Next()
		if err == iterator.Done {
			break
		}
		if err != nil {
			return nil, err
		}

		instances := pair.Value.Instances
		if len(instances) > 0 {
			for _, instance := range instances {
				instanceNames = append(instanceNames, instance.GetName())
			}
		}
	}

	return instanceNames, nil
}

func (c *ComputeEngineClient) GetInstanceNames(ctx context.Context) ([]string, error) {
	var instanceNames []string

	zc, err := compute.NewZonesRESTClient(ctx)
	if err != nil {
		return nil, err
	}

	zreq := &computepb.ListZonesRequest{
		Project: config.GetProjectID(),
	}
	zit := zc.List(ctx, zreq)

	for {
		zone, err := zit.Next()
		if err == iterator.Done {
			break
		}
		if err != nil {
			return nil, err
		}

		req := &computepb.ListInstancesRequest{
			Project: config.GetProjectID(),
			Zone:    zone.GetName(),
		}
		it := c.computeEngineClient.List(ctx, req)
		for {
			instance, err := it.Next()

			if err == iterator.Done {
				break
			}
			if err != nil {
				return nil, err
			}
			instanceNames = append(instanceNames, instance.GetName())
		}
	}

	return instanceNames, nil
}

func (c *ComputeEngineClient) StartInstanceNoWait(ctx context.Context, instanceName string) error {
	zone := "asia-northeast1-a"
	req := &computepb.StartInstanceRequest{
		Project:  config.GetProjectID(),
		Zone:     zone,
		Instance: instanceName,
	}

	_, err := c.computeEngineClient.Start(ctx, req)
	if err != nil {
		return err
	}

	return nil
}

func (c *ComputeEngineClient) StopInstanceNoWait(ctx context.Context, instanceName string) error {
	zone := "asia-northeast1-a"
	req := &computepb.StopInstanceRequest{
		Project:  config.GetProjectID(),
		Zone:     zone,
		Instance: instanceName,
	}

	_, err := c.computeEngineClient.Stop(ctx, req)
	if err != nil {
		return err
	}

	return nil
}
