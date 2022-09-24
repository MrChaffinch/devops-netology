# Домашнее задание к занятию "12.5 Сетевые решения CNI"
После работы с Flannel появилась необходимость обеспечить безопасность для приложения. Для этого лучше всего подойдет Calico.
## Задание 1: установить в кластер CNI плагин Calico
Для проверки других сетевых решений стоит поставить отличный от Flannel плагин — например, Calico. Требования: 
* установка производится через ansible/kubespray;
* после применения следует настроить политику доступа к hello-world извне. Инструкции [kubernetes.io](https://kubernetes.io/docs/concepts/services-networking/network-policies/), [Calico](https://docs.projectcalico.org/about/about-network-policy)

## Задание 2: изучить, что запущено по умолчанию
Самый простой способ — проверить командой calicoctl get <type>. Для проверки стоит получить список нод, ipPool и profile.
Требования: 
* установить утилиту calicoctl;
* получить 3 вышеописанных типа в консоли.

## ДЗ

Установим calico согласно с инструкции с ![официального сайта](https://projectcalico.docs.tigera.io/getting-started/kubernetes/self-managed-onprem/onpremises).  
Запустим наши поды через ``kubectl apply -f``, указав два наших манифеста. Проверим результат, выполнив ``kubectl get po``:
```shell
[root@node1 home]# kubectl get po
NAME                          READY   STATUS    RESTARTS   AGE
hello-node-7d9b4cbb65-28szf   1/1     Running   0          6m53s
hello-node-7d9b4cbb65-7f24q   1/1     Running   0          9m36s
hello-node-7d9b4cbb65-9xptc   1/1     Running   0          6m53s
multitool-59d899dd4b-kmxxx    1/1     Running   0          9m30s
```

Убедимся в доступности всех нод:
```shell
kubectl exec multitool-59d899dd4b-kmxxx -- curl -s hello-node-7d9b4cbb65-7f24q hello-node:8080```

Во всех случаях результат будет следующим:
```bash
CLIENT VALUES:
client_address=10.244.120.78
command=GET
real path=/
query=nil
request_version=1.1
request_uri=http://hello-node:8080/

SERVER VALUES:
server_version=nginx: 1.10.0 - lua: 10001

HEADERS RECEIVED:
accept=*/*
host=hello-node:8080
user-agent=curl/7.79.1
BODY:
-no body in request-%                                                  
```

Внедрим политику по запрету внутреннего трафика между POD-ами ``kubectl apply -f network-policy-block-ingress.yml`` и попробуем обратиться к сервису повторно:
```shell
kubectl exec multitool-59d899dd4b-kmxxx -- curl -s hello-node-7d9b4cbb65-7f24q hello-node:8080
command terminated with exit code 28
```
Внедрим сетевую политику, разрешающую входящий траффик из POD-ов multitool ``kubectl apply -f network-policy-allow-ingress.yml`` и проверим ещё раз:
```shell
kubectl exec multitool-59d899dd4b-kmxxx -- curl -s hello-node-7d9b4cbb65-7f24q hello-node:8080

CLIENT VALUES:
client_address=10.244.120.78
command=GET
real path=/
query=nil
request_version=1.1
request_uri=http://hello-node:8080/

SERVER VALUES:
server_version=nginx: 1.10.0 - lua: 10001

HEADERS RECEIVED:
accept=*/*
host=hello-node:8080
user-agent=curl/7.79.1
BODY:
-no body in request-%      
```
Таким образом мы настроили траффик исходящий из POD-ов мультитул. Для теста поднимем этот же деплоймент, но будем использовать другое имя, отличное от ``multitool``:
```shell
kubectl apply -f multitool.yml 
deployment.apps/multitool-2 created

kubectl get po                                            ✔  at minikube ⎈  at 12:33:12   
NAME                           READY   STATUS    RESTARTS   AGE
hello-node-7d9b4cbb65-28szf    1/1     Running   0          45m
hello-node-7d9b4cbb65-7f24q    1/1     Running   0          47m
hello-node-7d9b4cbb65-9xptc    1/1     Running   0          45m
multitool-2-58dd86f657-bb6ql   1/1     Running   0          15s
multitool-59d899dd4b-kmxxx     1/1     Running   0          47m
```
Попробуем обратиться к сервису из нового POD-a - multitool-2:
```shell
kubectl exec multitool-2-58dd86f657-bb6ql -- curl -s hello-node-7d9b4cbb65-7f24q hello-node:8080
command terminated with exit code 28
```
Ещё раз проверим доступность сервиса из POD-а, с меткой ``multitool``:
```shell
kubectl exec multitool-59d899dd4b-kmxxx -- curl -s hello-node-7d9b4cbb65-7f24q hello-node:8080
CLIENT VALUES:
client_address=10.244.120.78
command=GET
real path=/
query=nil
request_version=1.1
request_uri=http://hello-node:8080/

SERVER VALUES:
server_version=nginx: 1.10.0 - lua: 10001

HEADERS RECEIVED:
accept=*/*
host=hello-node:8080
user-agent=curl/7.79.1
BODY:
-no body in request-%                                                                                                                     ```
   
Установим утилиту ``calicoctl`` согласно инструкции на официальном сайте:
```shell
sudo curl -L https://github.com/projectcalico/calico/releases/download/v3.23.1/calicoctl-linux-amd64 -o /usr/bin/calicoctl
chmod +x /usr/bin/calicoctl 
```
И получим все требуемые значения:
```shell
calicoctl get nodes -o wide
Failed to get resources: Version mismatch.
Client Version:   v3.23.1
Cluster Version:  v3.20.0
Use --allow-version-mismatch to override.
```
Т.к. версия, используемая в minikube, более старая и не отсутствует среди пакетов - используем флаг ``--allow-version-mismatch`` и повторим запрос:
```shell
calicoctl get nodes -o wide --allow-version-mismatch
NAME       ASN       IPV4              IPV6   
minikube   (64512)   192.168.49.2/24 
```
Проверим IP-pool:
```shell
calicoctl get ippool -o wide --allow-version-mismatch

NAME                  CIDR            NAT    IPIPMODE   VXLANMODE   DISABLED   DISABLEBGPEXPORT   SELECTOR   
default-ipv4-ippool   10.244.0.0/16   true   Always     Never       false      false              all()      
```

Проверим профиль:
```shell
calicoctl get profile --allow-version-mismatch

NAME                                                 
projectcalico-default-allow                          
kns.default                                          
kns.kube-node-lease                                  
kns.kube-public                                      
kns.kube-system                                      
ksa.default.default                                  
ksa.kube-node-lease.default                          
ksa.kube-public.default                              
ksa.kube-system.attachdetach-controller              
ksa.kube-system.bootstrap-signer                     
ksa.kube-system.calico-kube-controllers              
ksa.kube-system.calico-node                          
ksa.kube-system.certificate-controller               
ksa.kube-system.clusterrole-aggregation-controller   
ksa.kube-system.coredns                              
ksa.kube-system.cronjob-controller                   
ksa.kube-system.daemon-set-controller                
ksa.kube-system.default                              
ksa.kube-system.deployment-controller                
ksa.kube-system.disruption-controller                
ksa.kube-system.endpoint-controller                  
ksa.kube-system.endpointslice-controller             
ksa.kube-system.endpointslicemirroring-controller    
ksa.kube-system.ephemeral-volume-controller          
ksa.kube-system.expand-controller                    
ksa.kube-system.generic-garbage-collector            
ksa.kube-system.horizontal-pod-autoscaler            
ksa.kube-system.job-controller                       
ksa.kube-system.kube-proxy                           
ksa.kube-system.namespace-controller                 
ksa.kube-system.node-controller                      
ksa.kube-system.persistent-volume-binder             
ksa.kube-system.pod-garbage-collector                
ksa.kube-system.pv-protection-controller             
ksa.kube-system.pvc-protection-controller            
ksa.kube-system.replicaset-controller                
ksa.kube-system.replication-controller               
ksa.kube-system.resourcequota-controller             
ksa.kube-system.root-ca-cert-publisher               
ksa.kube-system.service-account-controller           
ksa.kube-system.service-controller                   
ksa.kube-system.statefulset-controller               
ksa.kube-system.storage-provisioner                  
ksa.kube-system.token-cleaner                        
ksa.kube-system.ttl-after-finished-controller        
ksa.kube-system.ttl-controller                       
```