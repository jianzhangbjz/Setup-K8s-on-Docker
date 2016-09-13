# Setup-K8s-on-Docker
Setup single Kubernetes cluster on docker on x86 machine

Due to the Kubernetes haven't provide the official kubelet.tar file, so we need to build the kubelet image first.
```
git checkout kubelet-in-container
cd build-kubelet-image
cp /usr/local/kubelet .
cp /usr/local/nsenter .
make local-kubelet
```
For nsenter's install, please refer to https://github.com/jpetazzo/nsenter 
After that we can get the `gcr.io/google_containers/kubelet:latest` docker image.

Get etcd image, open your Kubernetes root folder, then we can find it after exec `docker images` command.
```
cd kubernetes/cluster/images/etcd/
make
```
Get and unzip kubernetes-server-linux-amd64.tar.gz, we can find it from `_output/release-tars/` folder.
```
tar -xvf kubernetes-server-linux-amd64.tar.gz
cd kubernetes/server/bin
```
Load kube-apiserver.tar/kube-controller-manager.tar/kube-scheduler.tar into docker images
```
docekr load --input kube-apiserver.tar
docker load --input kube-controller-manager.tar
docker load --input kube-scheduler.tar
docker load --input kube-proxy.tar
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
