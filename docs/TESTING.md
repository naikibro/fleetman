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

## 4. Check the Persistent Volume Claim bounding with Mongodb

Verify PVC status

```sh
kubectl get pvc mongo-data -n fleetman
kubectl describe pvc mongo-data -n fleetman

```

See that all mongo pods use the same pvc for persistent storage volume

```sh
kubectl describe pod -l app=fleetman-mongodb -n fleetman
```

### 4.1 - Test persistence

Get the mongo pods names

```sh
kgp -n fleetman
```

Insert test data, replace `<mongo-pod-name>` with one of your mongo pod name

```sh
kubectl exec -it <mongo-pod-name> -n fleetman -- mongo
```

```sh
use testdb
db.testcollection.insert({name: "Fleetman", value: "Test"})
db.testcollection.find()
```

**Delete the pod to simulate failure**

```sh
kubectl delete pod <mongo-pod-name> -n fleetman
```

**Verify data persitence**
Connect to the new pod generated

```sh
kubectl exec -it <new-mongo-pod-name> -n fleetman -- mongo
```

```sh
use testdb
db.testcollection.find()
```
