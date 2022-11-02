# Домашнее задание к занятию "14.2 Синхронизация секретов с внешними сервисами. Vault"

## Задача 1: Работа с модулем Vault

Запустить модуль Vault конфигураций через утилиту kubectl в установленном minikube

```
kubectl apply -f 14.2/vault-pod.yml
```

Получить значение внутреннего IP пода

```
kubectl get pod 14.2-netology-vault -o json | jq -c '.status.podIPs'
```

Примечание: jq - утилита для работы с JSON в командной строке

Запустить второй модуль для использования в качестве клиента

```
kubectl run -i --tty fedora --image=fedora --restart=Never -- sh
```

Установить дополнительные пакеты

```
dnf -y install pip
pip install hvac
```

Запустить интепретатор Python и выполнить следующий код, предварительно
поменяв IP и токен

```
import hvac
client = hvac.Client(
    url='10.244.120.91:8200',
    token='aiphohTaa0eeHei'
)
client.is_authenticated()

# Пишем секрет
client.secrets.kv.v2.create_or_update_secret(
    path='hvac',
    secret=dict(netology='Big secret!!!'),
)

# Читаем секрет
client.secrets.kv.v2.read_secret_version(
    path='hvac',
)
```

## Задача 2 (*): Работа с секретами внутри модуля

* На основе образа fedora создать модуль;
* Создать секрет, в котором будет указан токен;
* Подключить секрет к модулю;
* Запустить модуль и проверить доступность сервиса Vault.

---

## Решение.
Применим манифест и посмотрим на состояние POD-а:
```
kubectl apply -f 14.2/vault-pod.yml
pod/14.2-netology-vault created

kubectl get po
NAME                  READY   STATUS    RESTARTS   AGE
14.2-netology-vault   1/1     Running   0          28s
```

Получим значение внутреннего IP:
```
kubectl get pod 14.2-netology-vault -o json | jq -c '.status.podIPs'
[{"ip":"10.244.120.91"}]
```

Запустим второй контейнер и провалимся в него:
```
kubectl run -i --tty fedora --image=fedora --restart=Never -- sh
```
В соседнем терминале проверим статус контейнеров:
```
kubectl get po
NAME                  READY   STATUS    RESTARTS   AGE
14.2-netology-vault   1/1     Running   0          4m33s
fedora                1/1     Running   0          35s
```

Внутри контейнера выполним требуемые команды и установим нужные пакеты:
```
dnf -y install pip
pip install hvac
```

Запустим интерпритатор питона и выполним в нём требуемый код, заменив IP адрес значение текущего POD-а:
```
sh-5.1# python
---

import hvac
client = hvac.Client(
    url='http://10.244.120.91:8200',
    token='aiphohTaa0eeHei'
)
client.is_authenticated()


client.secrets.kv.v2.create_or_update_secret(
    path='hvac',
    secret=dict(netology='Big secret!!!'),
)


client.secrets.kv.v2.read_secret_version(
    path='hvac',
)
```
В результате получаем следующий вывод:
```
>>> import hvac
>>> client = hvac.Client(
...     url='http://10.244.120.91:8200',
...     token='aiphohTaa0eeHei'
... )
>>> client.is_authenticated()
create_or_update_secret(
    path='hvac',
    secret=dict(netology='Big secret!!!'),
)


client.secrTrue
>>> 
>>> 
>>> client.secrets.kv.v2.create_or_update_secret(
...     path='hvac',
...     secret=dict(netology='Big secret!!!'),
... )
ets.kv.v2.read_secret_version(
    path='hvac',
){'request_id': 'c7584aff-2326-2196-f7d9-43ad8183572d', 'lease_id': '', 'renewable': False, 'lease_duration': 0, 'data': {'created_time': '2022-08-20T10:47:56.688791541Z', 'custom_metadata': None, 'deletion_time': '', 'destroyed': False, 'version': 1}, 'wrap_info': None, 'warnings': None, 'auth': None}
>>> 
>>> 
>>> client.secrets.kv.v2.read_secret_version(
...     path='hvac',
... )
{'request_id': 'ed8123fa-969a-f012-a604-338f89cd1757', 'lease_id': '', 'renewable': False, 'lease_duration': 0, 'data': {'data': {'netology': 'Big secret!!!'}, 'metadata': {'created_time': '2022-08-20T10:47:56.688791541Z', 'custom_metadata': None, 'deletion_time': '', 'destroyed': False, 'version': 1}}, 'wrap_info': None, 'warnings': None, 'auth': None}
>>> 
```

---
