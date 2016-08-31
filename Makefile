# Kubernetes cluster setups

ip=9.186.50.250
log_level=3
etcd_server_port=2380
etcd_client_port=2379
apiserver_port=8080
kubelet_port=10250
service_ip_range=10.0.0.0/24

kill-all: kill-cluster-local detach-flannel-local kill-etcd-local

run-all: run-etcd-local setup-flannel-local run-cluster-local

run-cluster-local: run-apiserver-local sleep2 run-controller-manager-local sleep3 run-scheduler-local sleep4 run-proxy-local sleep1 run-kubelet-local

kill-cluster-local: kill-apiserver-local kill-controller-manager-local kill-scheduler-local kill-proxy-local kill-kubelet-local

setup-flannel-local: run-flannel setup-flannel-docker

detach-flannel-local: kill-flannel detach-flannel-docker

run-flannel:
	setsid flanneld \
	-etcd-endpoints http://${ip}:2379 \
	>> /var/log/flannel/flannel.log 2>&1 &

kill-flannel:
	killall flanneld

setup-flannel-docker:
	./flannel-docker-setup.sh

detach-flannel-docker:
	./flannel-docker-detach.sh

kill-etcd-local:
	killall etcd

kill-apiserver-local:
	killall kube-apiserver

kill-controller-manager-local:
	killall kube-controller-manager

kill-scheduler-local:
	killall kube-scheduler

kill-proxy-local:
	killall kube-proxy

kill-kubelet-local:
	killall kubelet

run-etcd-local:
	docker run -d -p 2379:2379 -p 2380:2380 --name etcd gcr.io/google_containers/etcd-amd64:2.2.5 etcd \
    --name etcd0 \
	--initial-advertise-peer-urls http://${ip}:${etcd_server_port} \
	--initial-cluster etcd0=http://${ip}:${etcd_server_port} \
	--listen-peer-urls http://0.0.0.0:${etcd_server_port} \
	--listen-client-urls http://0.0.0.0:${etcd_client_port} \
	--advertise-client-urls http://${ip}:${etcd_client_port} \
	--data-dir=/var/lib/etcd \

run-apiserver-local:
	docker run -d -p 8080:8080 --name apiserver gcr.io/google_containers/kube-apiserver:v1.0 kube-apiserver \
	--service-cluster-ip-range=${service_ip_range} \
	--insecure-bind-address=0.0.0.0 \
	--insecure-port=${apiserver_port} \
	--log_dir=/var/log/kubernetes \
	--v=${log_level} \
	--logtostderr=false \
	--etcd_servers=http://${ip}:2379 \
	--allow_privileged=false \

run-controller-manager-local:
	docker run -d --name controller-manager gcr.io/google_containers/kube-controller-manager:v1.0 kube-controller-manager  \
	--v=${log_level} \
	--logtostderr=false \
	--log_dir=/var/log/kubernetes \
	--master=${ip}:${apiserver_port} \

run-scheduler-local:
	docker run -d --name scheduler gcr.io/google_containers/kube-scheduler:v1.0 kube-scheduler \
	--master=${ip}:${apiserver_port} \
	--v=${log_level} \
	--log_dir=/var/log/kubernetes \

run-proxy-local:
	kube-proxy \
	--logtostderr=false \
	--v=${log_level} \
	--log_dir=/var/log/kubernetes \
	--hostname_override=${ip} \
	--master=http://${ip}:${apiserver_port} \
	> /dev/null 2>&1 &

run-kubelet-local:
	kubelet \
	--logtostderr=false \
	--v=${log_level} \
	--allow-privileged=false \
	--log_dir=/var/log/kubernetes \
	--address=0.0.0.0 \
	--port=${kubelet_port} \
	--hostname_override=${ip} \
	--api_servers=http://${ip}:${apiserver_port} \
	--cpu-cfs-quota=false \
	--cluster-dns=8.8.8.8 \
	> /dev/null 2>&1 &
sleep1:
	sleep 30
sleep2:
	sleep 30
sleep3:
	sleep 30
sleep4:
	sleep 30	
