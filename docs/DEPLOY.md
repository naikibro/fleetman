# DEPLOY.md

## Deploying a Kubernetes Cluster with Azure Kubernetes Service (AKS)

This document outlines the steps required to deploy a distributed Kubernetes cluster with one master node and two worker nodes, and deploy the Fleetman application.

---

## Step 1: Set Up Azure CLI

1. **Install Azure CLI:**

   Please refer to official Azure documentation for installation process

2. **Log in to Azure:**

   ```bash
   az login
   ```

3. **Set your default subscription (if you have multiple subscriptions):**
   ```bash
   az account set --subscription "YOUR_SUBSCRIPTION_ID"
   ```

---

## Step 2: Create an AKS Cluster

1. **Create a Resource Group:**
   Replace `<RESOURCE_GROUP_NAME>` and `<LOCATION>` with your desired names.

   ```bash
   az group create --name <RESOURCE_GROUP_NAME> --location <LOCATION>
   ```

2. **Create the AKS Cluster:**
   Specify the cluster name, node count, and VM size:

   ```bash
   az aks create \
     --resource-group <RESOURCE_GROUP_NAME> \
     --name <CLUSTER_NAME> \
     --node-count 2 \
     --enable-addons monitoring \
     --generate-ssh-keys \
     --node-vm-size Standard_DS2_v2
   ```

   - `--node-count 2`: Creates 2 worker nodes.
   - The master node is managed by Azure (no additional setup required).

---

## Step 3: Connect to the AKS Cluster

1. **Install `kubectl`:**

   ```bash
   sudo apt-get install -y kubectl
   ```

2. **Get the AKS credentials:**

   ```bash
   az aks get-credentials --resource-group <RESOURCE_GROUP_NAME> --name <CLUSTER_NAME>
   ```

3. **Verify the connection:**
   ```bash
   kubectl get nodes
   ```

---

## Step 4: Deploy the Fleetman Application

1. **Apply the Kubernetes manifests:**

   ```bash
   kubectl apply -f <path_to_your_yaml_files>
   ```

2. **Verify deployments and services:**
   ```bash
   kubectl get deployments -n fleetman
   kubectl get services -n fleetman
   ```

---

## Step 5: Access the Fleetman Web Application

1. **Check the `NodePort` service for the Fleetman Web App:**

   ```bash
   kubectl get service fleetman-webapp -n fleetman
   ```

2. **Access the application using:**

   ```text
   http://<NODE-IP>:<NODE-PORT>
   ```

   Replace `<NODE-IP>` with the IP of any Kubernetes node and `<NODE-PORT>` with the NodePort displayed in the service.

---

## Step 6: Simulate Node Failure

1. **Identify one of the worker nodes:**

   ```bash
   kubectl get nodes
   ```

2. **Drain the node to simulate a failure:**

   ```bash
   kubectl drain <NODE_NAME> --ignore-daemonsets --delete-emptydir-data
   ```

3. **Verify the application's resilience:**

   ```bash
   kubectl get pods -n fleetman
   ```

4. **Restore the node:**
   ```bash
   kubectl uncordon <NODE_NAME>
   ```

---

## Additional Notes

- Ensure that all services use the correct Spring profile (`production-microservice`) to enable inter-service communication.
- The `fleetman-webapp` image tag must be updated to `1.0.0` for Kubernetes deployments.
- If positions do not appear on the web app, restart the `fleetman-queue` deployment:
  ```bash
  kubectl rollout restart deployment fleetman-queue -n fleetman
  ```
