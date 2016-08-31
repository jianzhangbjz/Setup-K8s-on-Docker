# Setup-K8s-on-Docker
Setup single Kubernetes cluster on docker on x86 machine

Get etcd image, then we can find it after exec `docker images` command.
```
cd /kubernetes/cluster/images/etcd/
make
```
Get and unzip kubernetes-server-linux-amd64.tar.gz, we can find it from _output/release-tars/ folder.
```
tar -xvf kubernetes-server-linux-amd64.tar.gz
cd /kubernetes/server/bin
```
Load kube-apiserver.tar/kube-controller-manager.tar/kube-scheduler.tar into docker images
```
docekr load --input kube-apiserver.tar
docker load --input kube-controller-manager.tar
docker load --input kube-scheduler.tar
```
Run make command, notice modify the corresponding image tag and IP address in Makefile
```
make run-etcd-local
make run-cluster-local
```
Now, the K8s cluster is running, verification. You can create APP via yaml files now.
```
kubectl get pods
kubectl describe nodes
```
