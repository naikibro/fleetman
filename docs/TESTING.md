# TESTING.md

## Testing Procedures for Fleetman Distributed Application

### Prerequisites

- Ensure all deployments and services are applied in Kubernetes:
  ```sh
  ./run-cluster.sh
  ```

---

## 1. Verify Kubernetes Deployments and Services

### 1.1 Check Pod Status

Ensure all pods are running without errors:

```bash
kubectl get pods -n fleetman
```

### 1.2 Verify Services

Confirm all services are correctly exposed:

```bash
kubectl get services -n fleetman
```

---

## 2. Access the Web Application

### 2.1 Find the NodePort

Retrieve the NodePort for the web application:

```bash
kubectl get service fleetman-webapp -n fleetman
```

### 2.2 Access the Application

Use the NodePort to access the web application:

```text
http://127.0.0.1:<NODE-PORT>
```

Replace `<NODE-PORT>` with the NodePort displayed in the service.

---

## 3. Debugging Position Display Issues

### 3.1 Restart the Queue Service

If positions do not display on the web interface:

```bash
kubectl rollout restart deployment fleetman-queue -n fleetman
```

### 3.2 Verify the Logs

Check the logs for the `fleetman-queue` and `fleetman-position-simulator` pods for errors:

```bash
kubectl logs -n fleetman -l app=fleetman-queue
kubectl logs -n fleetman -l app=fleetman-position-simulator
```

---

## 4. Deploy cluster to Azure
