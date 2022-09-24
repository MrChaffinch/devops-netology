# Домашнее задание к занятию "13.2 разделы и монтирование"
Приложение запущено и работает, но время от времени появляется необходимость передавать между бекендами данные. А сам бекенд генерирует статику для фронта. Нужно оптимизировать это.
Для настройки NFS сервера можно воспользоваться следующей инструкцией (производить под пользователем на сервере, у которого есть доступ до kubectl):
* установить helm: curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
* добавить репозиторий чартов: helm repo add stable https://charts.helm.sh/stable && helm repo update
* установить nfs-server через helm: helm install nfs-server stable/nfs-server-provisioner

В конце установки будет выдан пример создания PVC для этого сервера.

## Задание 1: подключить для тестового конфига общую папку
В stage окружении часто возникает необходимость отдавать статику бекенда сразу фронтом. Проще всего сделать это через общую папку. Требования:
* в поде подключена общая папка между контейнерами (например, /static);
* после записи чего-либо в контейнере с беком файлы можно получить из контейнера с фронтом.

## Задание 2: подключить общую папку для прода
Поработав на stage, доработки нужно отправить на прод. В продуктиве у нас контейнеры крутятся в разных подах, поэтому потребуется PV и связь через PVC. Сам PV должен быть связан с NFS сервером. Требования:
* все бекенды подключаются к одному PV в режиме ReadWriteMany;
* фронтенды тоже подключаются к этому же PV с таким же режимом;
* файлы, созданные бекендом, должны быть доступны фронту.

---

## Решение
Отредактируем манифест, добавив в него маунты:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend-backend
  namespace: test
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
        volumeMounts:
        - name: front-back
          mountPath: "/static/"
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
        volumeMounts:
        - name: front-back
          mountPath: "/static/"
        ports:
        - containerPort: 9000
        env:
        - name: DATABASE_URL
          value: postgres://postgres:postgres@postgres:5432/news
      volumes:
      - name: front-back
        emptyDir: {}
```
Запустим и проверим:
```bash
kubectl apply -f frontend-backend.yml
deployment.apps/frontend-backend configured
service/frontend-backend unchanged

#зайдём внутрь созданного пода и создадим файл в /static/
kubectl -n test exec -it frontend-backend-7b6996486-d4cz7 -c frontend -- bash
root@frontend-backend-7b6996486-d4cz7:/app# touch /static/123
root@frontend-backend-7b6996486-d4cz7:/app# ls -la /static/
total 8
drwxrwxrwx 2 root root 4096 Sep 24 13:04 .
drwxr-xr-x 1 root root 4096 Sep 24 12:59 ..
-rw-r--r-- 1 root root    0 Sep 24 13:04 123

#зайдём внутрь другого пода и убедимся, что файл на месте
kubectl -n test exec -it frontend-backend-7b6996486-d4cz7 -c backend -- bash 
root@frontend-backend-7b6996486-d4cz7:/app# ls -la /static/
total 8
drwxrwxrwx 2 root root 4096 Sep 24 13:04 .
drwxr-xr-x 1 root root 4096 Sep 24 12:59 ..
-rw-r--r-- 1 root root    0 Sep 24 13:04 123
root@frontend-backend-7b6996486-d4cz7:/app# exit
```

## Задача 2
Изменим наши манифесты, добавив в них директивы PVC. Создадим все элементы топологии:
```bash
kubectl apply -f pv.yml -f pvc.yml -f db.yml -f frontend.yml -f backend.yml
```
Все манифесты находятся в каталоге ``task2``. После создания убедимся в том, что pv доступно и данные сохраняются между POD-ами:
```bash
root@frontend-5bd5db987b-mbbfl:/app# ls -la /static/pv/
total 8
drwxrwxrwx 2 root root 4096 Sep 24 17:57 .
drwxr-xr-x 3 root root 4096 Sep 24 17:57 ..
root@frontend-5bd5db987b-mbbfl:/app# touch /static/pv/file_from_frontend.yml
root@frontend-5bd5db987b-mbbfl:/app# ls -la /static/pv/
total 8
drwxrwxrwx 2 root root 4096 Sep 24 17:58 .
drwxr-xr-x 3 root root 4096 Sep 24 17:57 ..
-rw-r--r-- 1 root root    0 Sep 24 17:58 file_from_frontend.yml
root@frontend-5bd5db987b-mbbfl:/app# 
exit

kubectl -n prod exec -it backend-69c58946dd-xpls4 -- bash 
root@backend-69c58946dd-xpls4:/app# ls -ls /static/pv/
total 0
0 -rw-r--r-- 1 root root 0 Sep 24 17:58 file_from_frontend.yml
root@backend-69c58946dd-xpls4:/app# touch /static/pv/file_from_backend
root@backend-69c58946dd-xpls4:/app# ls -ls /static/pv/
total 0
0 -rw-r--r-- 1 root root 0 Sep 24 18:20 file_from_backend
0 -rw-r--r-- 1 root root 0 Sep 24 17:58 file_from_frontend.yml
root@backend-69c58946dd-xpls4:/app# exit

kubectl -n prod exec -it frontend-5bd5db987b-mbbfl -- bash 
root@frontend-5bd5db987b-mbbfl:/app# ls -la /static/pv/
total 8
drwxrwxrwx 2 root root 4096 Sep 24 18:20 .
drwxr-xr-x 3 root root 4096 Sep 24 17:57 ..
-rw-r--r-- 1 root root    0 Sep 24 18:20 file_from_backend
-rw-r--r-- 1 root root    0 Sep 24 17:58 file_from_frontend.yml
```
