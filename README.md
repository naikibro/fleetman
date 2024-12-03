# Fleetman Kubernetes Deployment

## About the project

Fleetman is a distributed application that enables real-time tracking of a fleet of vehicles performing deliveries.

**author:** [@naikibro](https://github.com/naikibro)

**project repository:** https://github.com/naikibro/fleetman

# Run the project locally

## 0 - Prerequisites

We recommend you install these prior to the cluster setup

- **Docker desktop:** latest
- **Kubernetes:** v1.30.2
- **kubectl** commands
- unix based OS ( preferably )
- bash

## 1 - Setup the cluster

Run the convenience [setup script](./run-cluster.sh)  
This script creates the fleetman namespace and launches the services and deployments declaratively based on the provided yaml files

It is idempotent and should work fine to deploy or redeploy the cluster after modification

```sh
./run-cluster.sh
```

After a sucessful cluster creation or update, a `deployment_report.md` file should be created at the root of this project

> Un document prouve qu'un cluster Kubernetes a été monté : 13 points

---

## Testing the cluster resilience

please refer to this [testing guide](./docs/TESTING.md)

---

## Cleanup

To remove all resources, delete the `fleetman` namespace:

```bash
kubectl delete namespace fleetman
```
