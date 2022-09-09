# Домашнее задание к занятию "12.1 Компоненты Kubernetes"

Вы DevOps инженер в крупной компании с большим парком сервисов. Ваша задача — разворачивать эти продукты в корпоративном кластере. 

## Задача 1: Установить Minikube

Для экспериментов и валидации ваших решений вам нужно подготовить тестовую среду для работы с Kubernetes. Оптимальное решение — развернуть на рабочей машине Minikube.

### Как поставить на AWS:
- создать EC2 виртуальную машину (Ubuntu Server 20.04 LTS (HVM), SSD Volume Type) с типом **t3.small**. Для работы потребуется настроить Security Group для доступа по ssh. Не забудьте указать keypair, он потребуется для подключения.
- подключитесь к серверу по ssh (ssh ubuntu@<ipv4_public_ip> -i <keypair>.pem)
- установите миникуб и докер следующими командами:
  - curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
  - chmod +x ./kubectl
  - sudo mv ./kubectl /usr/local/bin/kubectl
  - sudo apt-get update && sudo apt-get install docker.io conntrack -y
  - curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/
- проверить версию можно командой minikube version
- переключаемся на root и запускаем миникуб: minikube start --vm-driver=none
- после запуска стоит проверить статус: minikube status
- запущенные служебные компоненты можно увидеть командой: kubectl get pods --namespace=kube-system

### Для сброса кластера стоит удалить кластер и создать заново:
- minikube delete
- minikube start --vm-driver=none

Возможно, для повторного запуска потребуется выполнить команду: sudo sysctl fs.protected_regular=0

Инструкция по установке Minikube - [ссылка](https://kubernetes.io/ru/docs/tasks/tools/install-minikube/)

**Важно**: t3.small не входит во free tier, следите за бюджетом аккаунта и удаляйте виртуалку.

## Задача 2: Запуск Hello World
После установки Minikube требуется его проверить. Для этого подойдет стандартное приложение hello world. А для доступа к нему потребуется ingress.

- развернуть через Minikube тестовое приложение по [туториалу](https://kubernetes.io/ru/docs/tutorials/hello-minikube/#%D1%81%D0%BE%D0%B7%D0%B4%D0%B0%D0%BD%D0%B8%D0%B5-%D0%BA%D0%BB%D0%B0%D1%81%D1%82%D0%B5%D1%80%D0%B0-minikube)
- установить аддоны ingress и dashboard

## Задача 3: Установить kubectl

Подготовить рабочую машину для управления корпоративным кластером. Установить клиентское приложение kubectl.
- подключиться к minikube 
- проверить работу приложения из задания 2, запустив port-forward до кластера

## Задача 4 (*): собрать через ansible (необязательное)

Профессионалы не делают одну и ту же задачу два раза. Давайте закрепим полученные навыки, автоматизировав выполнение заданий  ansible-скриптами. При выполнении задания обратите внимание на доступные модули для k8s под ansible.
 - собрать роль для установки minikube на aws сервисе (с установкой ingress)
 - собрать роль для запуска в кластере hello world
  
  ---

```yaml
all:
  children:
    centos:
      hosts:
        host1:
          ansible_host: 84.252.128.150
---
После запустил команду ``ansible-playbook -i inventory.yml main.yaml``. Краткий итог выполнения:
```bash
TASK [minikube : include_tasks] ***************************************************************************************************************************************
task path: /Users/ilyamarin/PycharmProjects/devops-netology/12-kubernetes-01-intro/ansible/roles/minikube/tasks/main.yml:4
included: /Users/ilyamarin/PycharmProjects/devops-netology/12-kubernetes-01-intro/ansible/roles/minikube/tasks/run_container.yml for host1

TASK [minikube : run container with 3 replicas] ***********************************************************************************************************************
task path: /Users/ilyamarin/PycharmProjects/devops-netology/12-kubernetes-01-intro/ansible/roles/minikube/tasks/run_container.yml:2
changed: [host1] => {"changed": true, "cmd": ["kubectl", "create", "deployment", "hello-node", "--image=k8s.gcr.io/echoserver:1.4", "--replicas", "3"], "delta": "0:00:00.103869", "end": "2022-06-06 04:29:24.847486", "msg": "", "rc": 0, "start": "2022-06-06 04:29:24.743617", "stderr": "", "stderr_lines": [], "stdout": "deployment.apps/hello-node created", "stdout_lines": ["deployment.apps/hello-node created"]}

TASK [minikube : create service] **************************************************************************************************************************************
task path: /Users/ilyamarin/PycharmProjects/devops-netology/12-kubernetes-01-intro/ansible/roles/minikube/tasks/run_container.yml:6
changed: [host1] => {"changed": true, "cmd": ["kubectl", "expose", "deployment", "hello-node", "--type=LoadBalancer", "--port=8080"], "delta": "0:00:00.180302", "end": "2022-06-06 04:29:25.721751", "msg": "", "rc": 0, "start": "2022-06-06 04:29:25.541449", "stderr": "", "stderr_lines": [], "stdout": "service/hello-node exposed", "stdout_lines": ["service/hello-node exposed"]}
META: role_complete for host1
META: ran handlers
META: ran handlers

PLAY RECAP ************************************************************************************************************************************************************
host1                      : ok=20   changed=7    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```
После подключаемся по ssh и проверяем установку:
```bash
imarin@test-centos7~# kubectl version
WARNING: This version information is deprecated and will be replaced with the output from kubectl version --short.  Use --output=yaml|json to get the full version.
Client Version: version.Info{Major:"1", Minor:"24", GitVersion:"v1.24.0", GitCommit:"4ce5a8954017644c5420bae81d72b09b735c21f0", GitTreeState:"clean", BuildDate:"2022-05-03T13:46:05Z", GoVersion:"go1.18.1", Compiler:"gc", Platform:"linux/amd64"}
Kustomize Version: v4.5.4
Server Version: version.Info{Major:"1", Minor:"23", GitVersion:"v1.23.3", GitCommit:"816c97ab8cff8a1c72eccca1026f7820e93e0d25", GitTreeState:"clean", BuildDate:"2022-01-25T21:19:12Z", GoVersion:"go1.17.6", Compiler:"gc", Platform:"linux/amd64"}
imarin@test-centos7~# minikube status
minikube
type: Control Plane
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured
```
Проверяем включённые аддоны в minikube:
```bash
imarin@test-centos7~# minikube addons list
|-----------------------------|----------|--------------|--------------------------------|
|         ADDON NAME          | PROFILE  |    STATUS    |           MAINTAINER           |
|-----------------------------|----------|--------------|--------------------------------|
| ambassador                  | minikube | disabled     | third-party (ambassador)       |
| auto-pause                  | minikube | disabled     | google                         |
| csi-hostpath-driver         | minikube | disabled     | kubernetes                     |
| dashboard                   | minikube | enabled ✅   | kubernetes                     |
| default-storageclass        | minikube | enabled ✅   | kubernetes                     |
| efk                         | minikube | disabled     | third-party (elastic)          |
| freshpod                    | minikube | disabled     | google                         |
| gcp-auth                    | minikube | disabled     | google                         |
| gvisor                      | minikube | disabled     | google                         |
| helm-tiller                 | minikube | disabled     | third-party (helm)             |
| ingress                     | minikube | enabled ✅   | unknown (third-party)          |
| ingress-dns                 | minikube | disabled     | google                         |
| istio                       | minikube | disabled     | third-party (istio)            |
| istio-provisioner           | minikube | disabled     | third-party (istio)            |
| kong                        | minikube | disabled     | third-party (Kong HQ)          |
| kubevirt                    | minikube | disabled     | third-party (kubevirt)         |
| logviewer                   | minikube | disabled     | unknown (third-party)          |
| metallb                     | minikube | disabled     | third-party (metallb)          |
| metrics-server              | minikube | disabled     | kubernetes                     |
| nvidia-driver-installer     | minikube | disabled     | google                         |
| nvidia-gpu-device-plugin    | minikube | disabled     | third-party (nvidia)           |
| olm                         | minikube | disabled     | third-party (operator          |
|                             |          |              | framework)                     |
| pod-security-policy         | minikube | disabled     | unknown (third-party)          |
| portainer                   | minikube | disabled     | portainer.io                   |
| registry                    | minikube | disabled     | google                         |
| registry-aliases            | minikube | disabled     | unknown (third-party)          |
| registry-creds              | minikube | disabled     | third-party (upmc enterprises) |
| storage-provisioner         | minikube | enabled ✅   | google                         |
| storage-provisioner-gluster | minikube | disabled     | unknown (third-party)          |
| volumesnapshots             | minikube | disabled     | kubernetes                     |
|-----------------------------|----------|--------------|--------------------------------|
imarin@test-centos7~# 
```
Запуск плейбука осуществлялся командой ``kubectl create deployment hello-node --image=k8s.gcr.io/echoserver:1.4 --replicas 3``, поэтому создаётся 3 POD-а:
```bash
imarin@test-centos7~# kubectl get deployment
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
hello-node   3/3     3            3           17m
imarin@test-centos7~# kubectl get po
NAME                          READY   STATUS    RESTARTS   AGE
hello-node-6b89d599b9-4wj4n   1/1     Running   0          17m
hello-node-6b89d599b9-jmx6s   1/1     Running   0          17m
hello-node-6b89d599b9-kf8pn   1/1     Running   0          17m
imarin@test-centos7~# 
```
