# Домашнее задание к занятию "12.2 Команды для работы с Kubernetes"
Кластер — это сложная система, с которой крайне редко работает один человек. Квалифицированный devops умеет наладить работу всей команды, занимающейся каким-либо сервисом.
После знакомства с кластером вас попросили выдать доступ нескольким разработчикам. Помимо этого требуется служебный аккаунт для просмотра логов.

## Задание 1: Запуск пода из образа в деплойменте
Для начала следует разобраться с прямым запуском приложений из консоли. Такой подход поможет быстро развернуть инструменты отладки в кластере. Требуется запустить деплоймент на основе образа из hello world уже через deployment. Сразу стоит запустить 2 копии приложения (replicas=2). 

Требования:
 * пример из hello world запущен в качестве deployment
 * количество реплик в deployment установлено в 2
 * наличие deployment можно проверить командой kubectl get deployment
 * наличие подов можно проверить командой kubectl get pods

В прошлом задании было запущено 3 реплики в деплойменте при помощи команды: ``kubectl create deployment hello-node --image=k8s.gcr.io/echoserver:1.4 --replicas 3``. В результате получилось:  
```bash
imarin@test-centos7~# kubectl -n demo get deployment
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
hello-node   3/3     3            3           15m
imarin@test-centos7~# kubectl -n demo get po
NAME                          READY   STATUS    RESTARTS   AGE
hello-node-6b89d599b9-cnh67   1/1     Running   0          15m
hello-node-6b89d599b9-pq5dx   1/1     Running   0          15m
hello-node-6b89d599b9-qtcxd   1/1     Running   0          15m
```


## Задание 2: Просмотр логов для разработки
Разработчикам крайне важно получать обратную связь от штатно работающего приложения и, еще важнее, об ошибках в его работе. 
Требуется создать пользователя и выдать ему доступ на чтение конфигурации и логов подов в app-namespace.

Требования: 
 * создан новый токен доступа для пользователя
 * пользователь прописан в локальный конфиг (~/.kube/config, блок users)
 * пользователь может просматривать логи подов и их конфигурацию (kubectl logs pod <pod_id>, kubectl describe pod <pod_id>)

Создадим сервисный аккаунт:
```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: developer
  namespace: demo
```
Создадим роль:
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: developer-role
  namespace: demo
rules:
- apiGroups: [""]
  resources: ["pods", "pods/log"]
  verbs: ["get", "list", "describe"]
```
Эта роль позволит обращаться к подам и их логам в неймспейсе demo.  
Привяжем роль к сервисному аккаунту:
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pods-logs
  namespace: demo
subjects:
- kind: ServiceAccount
  name: developer
  namespace: demo
roleRef:
  kind: Role
  name: developer-role # this must match the name of the Role or ClusterRole you wish to bind to
  apiGroup: rbac.authorization.k8s.io
```
Получаем связку сервисный аккаунт-роль-неймспейс. Тем самым при обращении к kube-api в нейсмпейсе от имени сервисного акканта появляется возможность использовать глаголы ``get`` и ``list`` для ресурсов ``pods`` и подресурса ``pods/logs``.  
  
Для проверки вызовем список подов в неймспейсе ``demo``от имени сервисного аккаунта, используя конструкцию ``--as=system:serviceaccount:{namespace}:{user}``: 
```bash
imarin@test-centos7~# kubectl get pods --as=system:serviceaccount:demo:developer -n demo
NAME                          READY   STATUS    RESTARTS   AGE
hello-node-6b89d599b9-cnh67   1/1     Running   0          21m
hello-node-6b89d599b9-pq5dx   1/1     Running   0          21m
hello-node-6b89d599b9-qtcxd   1/1     Running   0          21m
```
Попробуем получить список всех секретов в том же самом неймспейсе:
```bash
imarin@test-centos7~# kubectl -n demo get secrets --as=system:serviceaccount:demo:developer
Error from server (Forbidden): secrets is forbidden: User "system:serviceaccount:demo:developer" cannot list resource "secrets" in API group "" in the namespace "demo"
```
Или список POD-ов, но в нейсмпейсе kube-sustem:
```bash
imarin@test-centos7~# kubectl -n kube-system get po --as=system:serviceaccount:demo:developer
Error from server (Forbidden): pods is forbidden: User "system:serviceaccount:demo:developer" cannot list resource "pods" in API group "" in the namespace "kube-system"
```


## Задание 3: Изменение количества реплик 
Поработав с приложением, вы получили запрос на увеличение количества реплик приложения для нагрузки. Необходимо изменить запущенный deployment, увеличив количество реплик до 5. Посмотрите статус запущенных подов после увеличения реплик. 

Требования:
 * в deployment из задания 1 изменено количество реплик на 5
 * проверить что все поды перешли в статус running (kubectl get pods)

Увеличим количество реплик в деплойменте и проверим их состояние:
```bash
imarin@test-centos7~# kubectl -n demo get po
NAME                          READY   STATUS    RESTARTS   AGE
hello-node-6b89d599b9-cnh67   1/1     Running   0          21m
hello-node-6b89d599b9-pq5dx   1/1     Running   0          21m
hello-node-6b89d599b9-qtcxd   1/1     Running   0          21m

imarin@test-centos7~# kubectl -n demo scale deployment hello-node --replicas=5
deployment.apps/hello-node scaled

imarin@test-centos7~# kubectl -n demo get po
NAME                          READY   STATUS    RESTARTS   AGE
hello-node-6b89d599b9-2rkhh   1/1     Running   0          8s
hello-node-6b89d599b9-cnh67   1/1     Running   0          27m
hello-node-6b89d599b9-pq5dx   1/1     Running   0          27m
hello-node-6b89d599b9-qtcxd   1/1     Running   0          27m
hello-node-6b89d599b9-sg57q   1/1     Running   0          8s
```
