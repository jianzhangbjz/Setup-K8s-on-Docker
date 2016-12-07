# Introduction:
 In Kubernetes system, when a Pod access services of other Pod, there are two ways: Environment variables and DNS.
 But, the service must be created before the Pod will use this service by Environment variables way.
 So, we use the DNS way.
# Create a Pod firstly
 kubectl create -f test_dns.yaml
# Create service
The kubectl run line below will create two nginx pods listening on port 80. 
It will also create a deployment named my-nginx to ensure that there are always two pods running.
```
kubectl run my-nginx --image=nginx --replicas=2 --port=80
```
Exposing your pods to the internet.
```
kubectl expose deployment my-nginx --port=80 --type=LoadBalancer
```
kubectl get services
```
root@heatonli-test1:~/test-scripts#  kubectl get services
NAME           CLUSTER-IP   EXTERNAL-IP   PORT(S)    AGE
kubernetes     10.0.0.1     <none>        443/TCP    1d
my-nginx       10.0.0.239   <pending>     80/TCP     56m
redis-master   10.0.0.245   <none>        6379/TCP   18h
```
# Authentication
Then, enter the test container, `docker exec -ti 7201231bb953 /bin/bash`, also can check it via `cat /etc/resolv.conf`.
```
root@test:/# apt-get install curl
root@test:/# curl http://my-nginx:80
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
root@test:/# exit
```
Now, we can discovery the my-nginx service by DNS in a Pod.
We can also exectue the following command via Pod:
```
root@heatonli-test1:~/test-scripts# kubectl exec test -- curl http://my-nginx:80
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
100   612  100   612    0     0  99237      0 --:--:-- --:--:-- --:--:--   99k
root@heatonli-test1:~/test-scripts#
```
