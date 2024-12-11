# Deployment on Digital Ocean

I used Digital Ocean to deploy my Kubernetes cluster
I used [this file](./k8s-1-31-1-do-5-sfo3-1733949564788-kubeconfig.yaml) to connect to the cluster

Connect to the production cluster context

```sh
doctl auth init
doctl kubernetes cluster kubeconfig save df9c967c-8df3-4753-8e25-8ccd200dd533
```

### Switch to the production cluster context

```sh
kubectl congif get-contexts
kubectl --kubeconfig=./k8s-1-31-1-do-5-sfo3-1733949564788-kubeconfig.yaml config use-context do-sfo3-k8s-1-31-1-do-5-sfo3-1733949564788
```

### Deploy the cluster to production

```sh
./run-cluster.sh
```

### Cleanup the cluster

```sh
kubectl delete namespace fleetman
```
