# Домашнее задание к занятию "14.1 Создание и использование секретов"

## Задача 1: Работа с секретами через утилиту kubectl в установленном minikube

Выполните приведённые ниже команды в консоли, получите вывод команд. Сохраните
задачу 1 как справочный материал.

### Как создать секрет?

```
openssl genrsa -out cert.key 4096
openssl req -x509 -new -key cert.key -days 3650 -out cert.crt \
-subj '/C=RU/ST=Moscow/L=Moscow/CN=server.local'
kubectl create secret tls domain-cert --cert=certs/cert.crt --key=certs/cert.key
```

### Как просмотреть список секретов?

```
kubectl get secrets
kubectl get secret
```

### Как просмотреть секрет?

```
kubectl get secret domain-cert
kubectl describe secret domain-cert
```

### Как получить информацию в формате YAML и/или JSON?

```
kubectl get secret domain-cert -o yaml
kubectl get secret domain-cert -o json
```

### Как выгрузить секрет и сохранить его в файл?

```
kubectl get secrets -o json > secrets.json
kubectl get secret domain-cert -o yaml > domain-cert.yml
```

### Как удалить секрет?

```
kubectl delete secret domain-cert
```

### Как загрузить секрет из файла?

```
kubectl apply -f domain-cert.yml
```

## Задача 2 (*): Работа с секретами внутри модуля

Выберите любимый образ контейнера, подключите секреты и проверьте их доступность
как в виде переменных окружения, так и в виде примонтированного тома.

---

### Решение

Решил идти сразу в задание со *, т.к. более ранние операции достаточно было лишь повторить.  
В качестве самой простой реализации решил взять контейнер ``nginx``, в котором решил изменить стартовую страницу выводящуюся по-умолчанию, а также пробросить внутрь POD-а пару переменных окружений, как требует задача.  
Создал секрет для переменных окружения:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: sensitive-secret
type: Opaque
data:
    USER_NAME: dXNlcm5hbWUK
    PASSWORD: cGEkJHcwcmQK
```
Для того, чтобы изменить поработать с секретом, подключаемым в качестве модуля, создал простой ``index.html`` с содержимым:
```html
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>This file comes from the secret k8s object</p>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```
И на его основании сделал секрет при помощи команды ``kubectl create secret generic secret-key --from-file index.html``.  
Проверим полученные секреты:
```bash
kubectl get secret             
NAME                  TYPE                                  DATA   AGE
default-token-v2sxc   kubernetes.io/service-account-token   3      37d
secret-key            Opaque                                1      16m
sensitive-secret      Opaque                                2      86m
```
Запустим POD, используя следующий манифест:
```yaml
apiVersion: v1
kind: Pod
metadata:
    name: nginx
    labels:
       app: front
       app: nginx
spec:
  volumes:
    - name: index-html
      secret:
        secretName: secret-key
  containers:
    - name: nginx
      image: nginx:latest
      ports:
        - containerPort: 80
      envFrom:
        - secretRef:
            name: sensitive-secret
      volumeMounts:
        - name: index-html
          mountPath: "/usr/share/nginx/html/"
          readOnly: true
```
В нём мы передаём переменные при помощи директивы ``envFrom``,  а также меняем стартовую страницу nginx, тестируя работу секрета в качестве файла. Как я понимаю, правильней делать это через configmap, но через секреты данный способ тоже реализуем.  
Для доступа к web-странице nginx создадим сервис типа ``nodePort``:
```yaml
apiVersion: v1
kind: Service
metadata: 
    name: nodeport-for-nginx
spec:
    type: NodePort
    selector:
       app: front
       app: nginx
    ports:
      - port: 80
        targetPort: 80
```
Применим в порядке:
* сервис
* секреты
* созданием POD-а

Проверим работоспособность и каждый компонент в отдельности:
```bash
kubectl get po,svc,secret                      
NAME        READY   STATUS    RESTARTS   AGE
pod/nginx   1/1     Running   0          22m

NAME                         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
service/kubernetes           ClusterIP   10.96.0.1       <none>        443/TCP        37d
service/nodeport-for-nginx   NodePort    10.109.95.243   <none>        80:31143/TCP   22m

NAME                         TYPE                                  DATA   AGE
secret/default-token-v2sxc   kubernetes.io/service-account-token   3      37d
secret/secret-key            Opaque                                1      22m
secret/sensitive-secret      Opaque                                2      93m

kubectl get nodes -o wide
NAME       STATUS   ROLES                  AGE   VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
minikube   Ready    control-plane,master   37d   v1.23.3   192.168.49.2   <none>        Ubuntu 20.04.4 LTS   5.15.0-41-generic   docker://20.10.17
```
Провалимся внутрь POD-а, чтоб проверить переменные окружения и посмотреть, что :
```bash
kubectl exec -it nginx -- bash

root@nginx:/# echo $USER_NAME
username
root@nginx:/# echo $PASSWORD 
pa$$w0rd


#проверим, что наша тестовая страница изменена
root@nginx:/# cat /usr/share/nginx/html/index.html 
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>This file comes from the secret k8s object</p> #вот оно - наше добавление :)
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```
Посмотрим состояние нод:
```bash
kubectl get nodes -o wide                                                    
NAME       STATUS   ROLES                  AGE   VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
minikube   Ready    control-plane,master   37d   v1.23.3   192.168.49.2   <none>        Ubuntu 20.04.4 LTS   5.15.0-41-generic   docker://20.10.17
```
Перейдём по адресу, добавив адрес ``NodePort``:
![image](https://user-images.githubusercontent.com/68470186/182029560-fe4d9786-87e7-4546-9d11-83a875fcee29.png)
