#!/bin/sh

# Namespace where the deployment exists
NAMESPACE="fleetman"

# Name of the deployment
DEPLOYMENT="fleetman-queue"

# Restart the deployment
echo "Restarting the deployment: $DEPLOYMENT in namespace: $NAMESPACE..."
kubectl rollout restart deployment $DEPLOYMENT -n $NAMESPACE

# Wait for the deployment to roll out
echo "Waiting for the deployment to roll out..."
kubectl rollout status deployment $DEPLOYMENT -n $NAMESPACE

# Confirm pods are running
echo "Checking the status of pods..."
kubectl get pods -n $NAMESPACE -l app=$DEPLOYMENT
