#!/bin/bash

# Exit script on error
set -e

# Variables
RESOURCE_GROUP_NAME="FleetmanResourceGroupLinux"
LOCATION="westus"
VM_NAME_PREFIX="FleetmanNode"
IMAGE="Canonical:UbuntuServer:18.04-LTS:latest"  # Ubuntu Linux
MANIFEST_PATH="." # Path to your Kubernetes manifest files

# Step 1: Create Resource Group and Virtual Machines
echo "Creating resource group..."
az group create --name $RESOURCE_GROUP_NAME --location $LOCATION

for i in 0 1 2; do
  echo "Creating Linux VM $VM_NAME_PREFIX-$i..."
  az vm create \
    --resource-group $RESOURCE_GROUP_NAME \
    --name "$VM_NAME_PREFIX-$i" \
    --image $IMAGE \
    --generate-ssh-keys
done

# Step 2: Install Kubernetes and Docker on Each Node
for i in 0 1 2; do
  echo "Setting up Kubernetes on $VM_NAME_PREFIX-$i..."
  az vm run-command invoke \
    --resource-group $RESOURCE_GROUP_NAME \
    --name "$VM_NAME_PREFIX-$i" \
    --command-id RunShellScript \
    --scripts "
    sudo apt-get update &&
    sudo apt-get install -y apt-transport-https curl &&
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - &&
    echo "deb https://apt.kubernetes.io/ kubernetes-bullseye main" | sudo tee /etc/apt/sources.list.d/kubernetes.list &&
    sudo apt-get update &&
    sudo apt-get install -y kubelet kubeadm kubectl
    "
done

# Step 3: Initialize Kubernetes Master Node
echo "Initializing Kubernetes master node..."
az vm run-command invoke \
  --resource-group $RESOURCE_GROUP_NAME \
  --name "$VM_NAME_PREFIX-0" \
  --command-id RunShellScript \
  --scripts "
    sudo kubeadm init --pod-network-cidr=10.244.0.0/16 &&
    mkdir -p \$HOME/.kube &&
    sudo cp -i /etc/kubernetes/admin.conf \$HOME/.kube/config &&
    sudo chown \$(id -u):\$(id -g) \$HOME/.kube/config
  "

# Step 4: Join Worker Nodes to the Cluster
JOIN_COMMAND=$(az vm run-command invoke \
  --resource-group $RESOURCE_GROUP_NAME \
  --name "$VM_NAME_PREFIX-0" \
  --command-id RunShellScript \
  --scripts "kubeadm token create --print-join-command" \
  --query "value" -o tsv)

for i in 1 2; do
  echo "Joining $VM_NAME_PREFIX-$i to the Kubernetes cluster..."
  az vm run-command invoke \
    --resource-group $RESOURCE_GROUP_NAME \
    --name "$VM_NAME_PREFIX-$i" \
    --command-id RunShellScript \
    --scripts "sudo $JOIN_COMMAND"
done

# Step 5: Deploy Networking (Flannel)
echo "Deploying flannel network..."
az vm run-command invoke \
  --resource-group $RESOURCE_GROUP_NAME \
  --name "$VM_NAME_PREFIX-0" \
  --command-id RunShellScript \
  --scripts "
    kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
  "

# Step 6: Deploy the Fleetman Application
echo "Deploying Fleetman application..."
az vm run-command invoke \
  --resource-group $RESOURCE_GROUP_NAME \
  --name "$VM_NAME_PREFIX-0" \
  --command-id RunShellScript \
  --scripts "
    mkdir -p ~/fleetman &&
    cp -r $MANIFEST_PATH/* ~/fleetman/ &&
    cd ~/fleetman &&
    ./run-cluster.sh
  "

# Step 7: Fetch NodePort for Web App
echo "Fetching NodePort for fleetman-web-app..."
az vm run-command invoke \
  --resource-group $RESOURCE_GROUP_NAME \
  --name "$VM_NAME_PREFIX-0" \
  --command-id RunShellScript \
  --scripts "
    kubectl get svc fleetman-webapp -o jsonpath='{.spec.ports[0].nodePort}'
  "

echo "Fleetman application deployed. Access it using the NodePort listed above."
