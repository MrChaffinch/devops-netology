# Домашнее задание к занятию "13.1 контейнеры, поды, deployment, statefulset, services, endpoints"
Настроив кластер, подготовьте приложение к запуску в нём. Приложение стандартное: бекенд, фронтенд, база данных. Его можно найти в папке 13-kubernetes-config.

## Задание 1: подготовить тестовый конфиг для запуска приложения
Для начала следует подготовить запуск приложения в stage окружении с простыми настройками. Требования:
* под содержит в себе 2 контейнера — фронтенд, бекенд;
* регулируется с помощью deployment фронтенд и бекенд;
* база данных — через statefulset.

## Задание 2: подготовить конфиг для production окружения
Следующим шагом будет запуск приложения в production окружении. Требования сложнее:
* каждый компонент (база, бекенд, фронтенд) запускаются в своем поде, регулируются отдельными deployment’ами;
* для связи используются service (у каждого компонента свой);
* в окружении фронта прописан адрес сервиса бекенда;
* в окружении бекенда прописан адрес сервиса базы данных.

## Задание 3 (*): добавить endpoint на внешний ресурс api
Приложению потребовалось внешнее api, и для его использования лучше добавить endpoint в кластер, направленный на это api. Требования:
* добавлен endpoint до внешнего api (например, геокодер).

---

# Решение
Сначала выполним первый пункт. В качестве приложений собрал два docker-контейнера из соответствующей директории. Создадим два манифеста для k8s:
* frontend-backend приложения
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend-backend
  namespace: default
spec:
  selector:
    matchLabels:
      app: frontend-backend
  template:
    metadata:
      labels:
        app: frontend-backend
    spec:
      containers:
      - name: frontend
        image: mbagirov/netology-13-front
        resources:
          limits:
            memory: "128Mi"
            cpu: "500m"
        ports:
        - containerPort: 80
        env: 
        - name: BASE_URL
          value: http://localhost:9000
      - name: backend
        image: mbagirov/netology-13-backend
        resources:
          limits:
            memory: "128Mi"
            cpu: "500m"
        ports:
        - containerPort: 9000
        env:
        - name: DATABASE_URL
          value: postgres://postgres:postgres@postgres:5432/news
---
apiVersion: v1
kind: Service
metadata:
  name: frontend-backend
  namespace: default
spec:
  selector:
    app: frontend-backend
  ports:
    - name: frontend
      protocol: TCP
      port: 8080
      targetPort: 80
    - name: backend
      protocol: TCP
      port: 9000
      targetPort: 9000
```
* db
```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: db
spec:
  selector:
    matchLabels:
      app: db
  serviceName: db
  replicas: 2
  template:
    metadata:
      labels:
        app: db
    spec:
      containers:
      - name: db
        image: postgres:13-alpine
        ports:
        - containerPort: 5432
        volumeMounts:
        - name: db-data
          mountPath: "/var/lib/postgresql/data"
        env:
        - name: POSTGRES_PASSWORD
          value: postgres
        - name: POSTGRES_USER
          value: postgres
        - name: POSTGRES_DB
          value: news
  volumeClaimTemplates:
  - metadata:
      name: db-data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 2Gi
---
apiVersion: v1
kind: Service
metadata:
  name: db
  namespace: default
spec:
  selector:
    app: db
  ports:
    - name: db
      protocol: TCP
      port: 5432
      targetPort: 5432
  type: ClusterIP

```
Порт ``9000`` взял из докерфайла. Раз он используется - значит его надо открыть. Порт 80 - взял стандартным для frontned-приложения. Для postgresql базы данных взял данные из окружения и использовал их в манифесте. В результате получил следующее:
- состояние POD-ов:
```shell
kubectl get po -o wide
NAME                               READY   STATUS    RESTARTS   AGE   IP              NODE       NOMINATED NODE   READINESS GATES
db-0                               1/1     Running   0          18m   10.244.120.82   minikube   <none>           <none>
db-1                               1/1     Running   0          18m   10.244.120.83   minikube   <none>           <none>
frontend-backend-554fc59d8-x7x7h   2/2     Running   0          13m   10.244.120.84   minikube   <none>           <none>

```
- состояние деплойментов:
```shell
kubectl get deployments.apps
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
frontend-backend   1/1     1            1           11m
```
- состояние сервисов и эндпоинтов:
```bash
kubectl get svc -o wide
NAME               TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)             AGE   SELECTOR
db                 ClusterIP   10.103.51.198    <none>        5432/TCP            18m   app=db
frontend-backend   ClusterIP   10.110.239.127   <none>        8080/TCP,9000/TCP   12m   app=frontend-backend
kubernetes         ClusterIP   10.96.0.1        <none>        443/TCP             37h   <none>


kubectl get ep
NAME               ENDPOINTS                               AGE
db                 10.244.120.82:5432,10.244.120.83:5432   18m
frontend-backend   10.244.120.84:9000,10.244.120.84:80     12m
kubernetes         192.168.49.2:8443                       37h
```
- состояние sts:
```bash
kubectl get sts -o wide
NAME   READY   AGE   CONTAINERS   IMAGES
db     2/2     19m   db           postgres:13-alpine
```
Проверяем настройки сервисов:
```bash
kubectl describe svc frontend-backend
Name:              frontend-backend
Namespace:         default
Labels:            <none>
Annotations:       <none>
Selector:          app=frontend-backend
Type:              ClusterIP
IP Family Policy:  SingleStack
IP Families:       IPv4
IP:                10.110.239.127
IPs:               10.110.239.127
Port:              frontend  8080/TCP
TargetPort:        80/TCP
Endpoints:         10.244.120.84:80
Port:              backend  9000/TCP
TargetPort:        9000/TCP
Endpoints:         10.244.120.84:9000
Session Affinity:  None
Events:            <none>
############################
kubectl describe svc db
Name:              db
Namespace:         default
Labels:            <none>
Annotations:       <none>
Selector:          app=db
Type:              ClusterIP
IP Family Policy:  SingleStack
IP Families:       IPv4
IP:                10.103.51.198
IPs:               10.103.51.198
Port:              db  5432/TCP
TargetPort:        5432/TCP
Endpoints:         10.244.120.82:5432,10.244.120.83:5432
Session Affinity:  None
Events:            <none>
```
Зайдём внутрь frontend-приложения и проверим работу:
```bash
root@frontend-backend-554fc59d8-x7x7h:/app# curl 10.110.239.127:8080
<!DOCTYPE html>
<html lang="ru">
<head>
    <title>Список</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="/build/main.css" rel="stylesheet">
</head>
<body>
    <main class="b-page">
        <h1 class="b-page__title">Список</h1>
        <div class="b-page__content b-items js-list"></div>
    </main>
    <script src="/build/main.js"></script>
</body>
</html>root@frontend-backend-554fc59d8-x7x7h:/app# 
```
На порт 9000 почему-то не откликается. Возможно, ошибка в исходном приложении, так как при сборке докер-контейнера сыпались ошибки...
```bash
root@frontend-backend-554fc59d8-x7x7h:/app# curl 10.110.239.127:9000
curl: (7) Failed to connect to 10.110.239.127 port 9000: Connection refused
```
---
### Задание 2
Разобьём манифест, в котором содержались одновременно frontend и backend приложение, на два самостоятельных манифеста и разместим в папку task2:
```yaml
#frontend приложение
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: default
spec:
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - name: frontend
        image: mbagirov/netology-13-front
        resources:
          limits:
            memory: "128Mi"
            cpu: "500m"
        ports:
        - containerPort: 80
        env: 
        - name: BASE_URL
          value: http://localhost:9000
---
apiVersion: v1
kind: Service
metadata:
  name: frontend
  namespace: default
spec:
  selector:
    app: frontend
  ports:
    - name: frontend
      protocol: TCP
      port: 8080
      targetPort: 80
```
```yaml
#backend приложение
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  namespace: default
spec:
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: backend
        image: mbagirov/netology-13-backend
        resources:
          limits:
            memory: "128Mi"
            cpu: "500m"
        ports:
        - containerPort: 9000
        env:
        - name: DATABASE_URL
          value: postgres://postgres:postgres@postgres:5432/news
---
apiVersion: v1
kind: Service
metadata:
  name: backend
  namespace: default
spec:
  selector:
    app: backend
  ports:
    - name: backend
      protocol: TCP
      port: 9000
      targetPort: 9000
```
Манифест для базы данных не требуется менять.  
Запустим приложения через ``kubectl apply -f`` и посмотрим состояние компонентов:
```bash
kubectl apply -f backend.yml -f frontend.yml                       ✔  at minikube ⎈  at 08:21:32   
deployment.apps/backend created
service/backend created
deployment.apps/frontend created
service/frontend created

#смотрим на наши POD-ы
kubectl get po
NAME                       READY   STATUS    RESTARTS   AGE
backend-6f94564b6d-ljhbm   1/1     Running   0          28s
db-0                       1/1     Running   0          8m21s
db-1                       1/1     Running   0          8m20s
frontend-6955c6bd6-4wxrs   1/1     Running   0          28s

#смотрим на деплойменты и стейтфулсеты
kubectl get deployments.apps,sts                                   ✔  at minikube ⎈  at 08:30:39   
NAME                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/backend    1/1     1            1           91s
deployment.apps/frontend   1/1     1            1           91s

NAME                  READY   AGE
statefulset.apps/db   2/2     9m24s

#проверяем сервисы и эндпоинты
get svc,ep -o wide                                         ✔  at minikube ⎈  at 08:30:55   
NAME                 TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE     SELECTOR
service/backend      ClusterIP   10.101.224.126   <none>        9000/TCP   2m15s   app=backend
service/db           ClusterIP   10.109.21.222    <none>        5432/TCP   10m     app=db
service/frontend     ClusterIP   10.98.130.132    <none>        8080/TCP   2m15s   app=frontend
service/kubernetes   ClusterIP   10.96.0.1        <none>        443/TCP    46h     <none>

NAME                   ENDPOINTS                               AGE
endpoints/backend      10.244.120.88:9000                      2m15s
endpoints/db           10.244.120.85:5432,10.244.120.86:5432   10m
endpoints/frontend     10.244.120.87:80                        2m15s
endpoints/kubernetes   192.168.49.2:8443                       46h
```
Проверим работоспособность на примере frontend-приложения. Зайдём в ноду и оттуда сделаем курл по нашему адресу:
```bash
#подключаемся к миникубу 
minikube ssh -n minikube

#проверяем работоспособность приложения
docker@minikube:~$ curl 10.244.120.87:80
<!DOCTYPE html>
<html lang="ru">
<head>
    <title>Список</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="/build/main.css" rel="stylesheet">
</head>
<body>
    <main class="b-page">
        <h1 class="b-page__title">Список</h1>
        <div class="b-page__content b-items js-list"></div>
    </main>
    <script src="/build/main.js"></script>
</body>
</html>docker@minikube:~$ 
```
