# Test the cluster resilience

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
- Access the application via: `http://127.0.0.1:<NODE-PORT>`

Replace `<NODE-PORT>` with the port shown under `NodePort`.

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
