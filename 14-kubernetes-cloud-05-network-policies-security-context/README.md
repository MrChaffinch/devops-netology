# Домашнее задание к занятию "14.5 SecurityContext, NetworkPolicies"

## Задача 1: Рассмотрите пример 14.5/example-security-context.yml

Создайте модуль

```
kubectl apply -f 14.5/example-security-context.yml
```

Проверьте установленные настройки внутри контейнера

```
kubectl logs security-context-demo
uid=1000 gid=3000 groups=3000
```

## Задача 2 (*): Рассмотрите пример 14.5/example-network-policy.yml

Создайте два модуля. Для первого модуля разрешите доступ к внешнему миру
и ко второму контейнеру. Для второго модуля разрешите связь только с
первым контейнером. Проверьте корректность настроек.

---

## Решение
Выполним треубемую команду:
```
kubectl apply -f 14.5/example-security-context.yml
pod/security-context-demo created
```
Проверим, что создалось:
```
kubectl get po

NAME                    READY   STATUS      RESTARTS      AGE
security-context-demo   0/1     Completed   5 (94s ago)   3m23s
```
Проверим логи POD-а:
```
kubectl logs security-context-demo
uid=1000 gid=3000 groups=3000
```
Проверим, что настроено в POD-е:
```
apiVersion: v1
kind: Pod
metadata:
  name: security-context-demo
spec:
  containers:
  - name: sec-ctx-demo
    image: fedora:latest
    command: [ "id" ]
    # command: [ "sh", "-c", "sleep 1h" ]
    securityContext:
      runAsUser: 1000
      runAsGroup: 3000    
```
POD находится в таком состоянии, т.к. на запуск у него стоит лишь ID. Раскоментируем ``command: [ "sh", "-c", "sleep 1h" ]`` и запустим повторно:
```
kubectl get po
NAME                    READY   STATUS    RESTARTS   AGE
security-context-demo   1/1     Running   0          4s
```
Проверим, что за пользователь находится внутри:
```
sh-5.1$ id
uid=1000 gid=3000 groups=3000
```
Тем самым мы запустили POD с требуемыми значениями.
---
Перейдём к заданию повышенной сложности.  
Закроем весь входящий траффик для POD-а, создаваемого по манифесту из задания (после небольшой модификации и добавления в него labels).
```
kubectl apply -f 14.5/policies/Ingress/00-deny-ingress-all.yml 
networkpolicy.networking.k8s.io/deny-ingress-all created
```
Создадим деплоймент для Multitool, воспользовавшись готовым манифестом:
```
kubectl create deployment multitool --image=praqma/network-multitool
#проверим POD-ы

kubectl get po -o wide  
NAME                         READY   STATUS    RESTARTS   AGE   IP               NODE       NOMINATED NODE   READINESS GATES
multitool-546689b6bb-9dx6c   1/1     Running   0          55s   10.244.120.115   minikube   <none>           <none>
security-context-demo        1/1     Running   0          16m   10.244.120.112   minikube   <none>           <none>
```
Проверим пинг:
```
kubectl exec -it multitool-546689b6bb-9dx6c bash
kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl exec [POD] -- [COMMAND] instead.
bash-5.1# ping 10.240.120.112
PING 10.240.120.112 (10.240.120.112) 56(84) bytes of data.
^C
--- 10.240.120.112 ping statistics ---
11 packets transmitted, 0 received, 100% packet loss, time 10219ms

bash-5.1# 
```
Т.к. мы запретили доступ к POD-у - ping не работает. Добавим правило:
```
kubectl apply -f 14.5/policies/Ingress/01-allow-internal-network.yml
networkpolicy.networking.k8s.io/allow-multitool-traffic created
```
Проверим пинг:
```
kubectl exec -it multitool-546689b6bb-9dx6c bash                    
kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl exec [POD] -- [COMMAND] instead.
bash-5.1# ping 10.244.120.112
PING 10.244.120.112 (10.244.120.112) 56(84) bytes of data.
64 bytes from 10.244.120.112: icmp_seq=1 ttl=63 time=0.131 ms
64 bytes from 10.244.120.112: icmp_seq=2 ttl=63 time=0.088 ms
^C
--- 10.244.120.112 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1009ms
```
Добавим правило, запрещающее весь исходящий траффик:
```
kubectl apply -f 14.5/policies/Egress/00-deny-all-egress.yml 
networkpolicy.networking.k8s.io/default-deny-egress created
```
Проверим доступность внешних ресурсов:
```
kubectl exec -it multitool-546689b6bb-9dx6c bash            
kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl exec [POD] -- [COMMAND] instead.
bash-5.1# ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
^C
--- 8.8.8.8 ping statistics ---
4 packets transmitted, 0 received, 100% packet loss, time 3049ms

bash-5.1# 
```
Добавим правило для конкретного POD-а:
```
kubectl apply -f 14.5/policies/Egress/01-allow-access-multitool.yml
networkpolicy.networking.k8s.io/allow-multitool-to-internet created
```
Проверим ping:
```
kubectl exec -it multitool-546689b6bb-9dx6c bash
kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl exec [POD] -- [COMMAND] instead.
bash-5.1# ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=104 time=48.3 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=104 time=42.9 ms
^C
--- 8.8.8.8 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1001ms
rtt min/avg/max/mdev = 42.924/45.626/48.328/2.702 ms
bash-5.1# c
```
Таким образом получилась следующая схема:
* двум POD-ам полностью ограничил ingress и egress траффик;
* разрешил ingress траффик из POD-а ``multitool`` в pod, созданный по манифесту из задания;
* разрешил egress траффик для POD-a ``multitool`` в интернет;