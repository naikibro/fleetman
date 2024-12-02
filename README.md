# Fleetman Kubernetes Deployment

## Cluster Setup

### 1. Provision a Kubernetes Cluster

- Ensure your Kubernetes cluster has **1 master node** and **2 worker nodes**.
- Use tools like `kubeadm`, `kops`, or `kubespray` for setup.
- Verify that the cluster is functional and `kubectl` is configured:
  ```bash
  kubectl get nodes
  ```

### 2. Create the `fleetman` Namespace

- All resources will be deployed in the `fleetman` namespace.
  ```bash
  kubectl create namespace fleetman
  ```

---

## Deployment

### 1. Apply Manifests in Order

Run the following commands to deploy the components in sequence:

#### **MongoDB PVC**

- Apply the Persistent Volume Claim for MongoDB:
  ```bash
  kubectl apply -f fleetman-mongodb-pvc.yaml -n fleetman
  ```

#### **MongoDB Deployment and Service**

- Deploy MongoDB and expose it via a `ClusterIP` service:
  ```bash
  kubectl apply -f fleetman-mongodb-deployment.yaml -n fleetman
  kubectl apply -f fleetman-mongodb-service.yaml -n fleetman
  ```

#### **Other Components**

- Deploy each microservice and expose them via appropriate services:

##### **Position Simulator**

```bash
kubectl apply -f fleetman-position-simulator-deployment.yaml -n fleetman
kubectl apply -f fleetman-position-simulator-service.yaml -n fleetman
```

##### **Queue (ActiveMQ)**

```bash
kubectl apply -f fleetman-queue-deployment.yaml -n fleetman
kubectl apply -f fleetman-queue-service.yaml -n fleetman
```

##### **Position Tracker**

```bash
kubectl apply -f fleetman-position-tracker-deployment.yaml -n fleetman
kubectl apply -f fleetman-position-tracker-service.yaml -n fleetman
```

##### **API Gateway**

```bash
kubectl apply -f fleetman-api-gateway-deployment.yaml -n fleetman
kubectl apply -f fleetman-api-gateway-service.yaml -n fleetman
```

##### **Web App**

- Deploy the Web App and expose it via a `NodePort` service:

```bash
kubectl apply -f fleetman-webapp-deployment.yaml -n fleetman
kubectl apply -f fleetman-webapp-service.yaml -n fleetman
```

---

## Testing

### 1. Verify Pods and Services

- Check the status of all pods:
  ```bash
  kubectl get pods -n fleetman
  ```
- Verify that all services are running:
  ```bash
  kubectl get services -n fleetman
  ```

### 2. Access the Web App

- Find the `NodePort` for the Web App:
  ```bash
  kubectl get service fleetman-webapp -n fleetman
  ```
- Access the application via: `http://<NODE-IP>:<NODE-PORT>`

Replace `<NODE-IP>` with the IP address of a Kubernetes node and `<NODE-PORT>` with the port shown under `NodePort`.

---

## Simulating Node Failures

### 1. Drain a Node

- Simulate a node failure by draining a worker node:
  ```bash
  kubectl drain <NODE-NAME> --ignore-daemonsets --delete-emptydir-data
  ```
- Check if the application continues to run on the remaining nodes:
  ```bash
  kubectl get pods -n fleetman
  ```

### 2. Uncordon the Node

- Once testing is complete, restore the node:
  ```bash
  kubectl uncordon <NODE-NAME>
  ```

---

## Notes

1. MongoDB uses a Persistent Volume Claim (PVC) to retain data even if the pod is deleted or restarted.
2. The Web App is exposed via a `NodePort` service for simplicity, allowing external access without an Ingress Controller.
3. The application is designed to continue running in the event of a node failure, provided sufficient resources are available on the remaining nodes.

---

## Cleanup

To remove all resources, delete the `fleetman` namespace:

```bash
kubectl delete namespace fleetman
```
