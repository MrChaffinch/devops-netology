# Домашнее задание к занятию "12.4 Развертывание кластера на собственных серверах, лекция 2"
Новые проекты пошли стабильным потоком. Каждый проект требует себе несколько кластеров: под тесты и продуктив. Делать все руками — не вариант, поэтому стоит автоматизировать подготовку новых кластеров.

## Задание 1: Подготовить инвентарь kubespray
Новые тестовые кластеры требуют типичных простых настроек. Нужно подготовить инвентарь и проверить его работу. Требования к инвентарю:
* подготовка работы кластера из 5 нод: 1 мастер и 4 рабочие ноды;
* в качестве CRI — containerd;
* запуск etcd производить на мастере.

## Задание 2 (*): подготовить и проверить инвентарь для кластера в AWS
Часть новых проектов хотят запускать на мощностях AWS. Требования похожи:
* разворачивать 5 нод: 1 мастер и 4 рабочие ноды;
* работать должны на минимально допустимых EC2 — t3.small.

---

После одобрения со стороны преподавателя было решено немного отойти от первоначального домашнего задания в сторону разворачивания отказоустойчивого кластера при помощи kubeadm.  
В итоге получилась вот такая картина:
```bash
NAME               STATUS   ROLES                  AGE   VERSION
k8s-master-node0   Ready    control-plane,master   3d   v1.23.4
k8s-master-node1   Ready    control-plane,master   3d   v1.23.4
k8s-master-node2   Ready    control-plane,master   3d   v1.23.4
k8s-worker-node0   Ready    <none>                 3d   v1.23.4
k8s-worker-node1   Ready    <none>                 3d   v1.23.4
k8s-worker-node2   Ready    <none>                 3d   v1.23.4
```
Первым делом на каждую ноду были установлены компоненты: kubeadm, kubectl, kubelet. Было решено хранить etcd на каждой master-ноде и не выносить в отдельный кластер.  
В сборке отсутствовал внешний балансировщик нагрузки, в связи с чем было принято решение поднять виртуальный IP (VIP) и настроить балансировку на него. Компоненты, которые использовались на мастер-нодах: keepalived (для VIP), HAproxy (для балансировки траффика).  
На каждой мастер-ноде был установлен HAproxy со следующей конфигурацией:
```yaml
#---------------------------------------------------------------------
# Global settings
#---------------------------------------------------------------------
global
    # to have these messages end up in /var/log/haproxy.log you will
    # need to:
    #
    # 1) configure syslog to accept network log events.  This is done
    #    by adding the '-r' option to the SYSLOGD_OPTIONS in
    #    /etc/sysconfig/syslog
    #
    # 2) configure local2 events to go to the /var/log/haproxy.log
    #   file. A line like the following can be added to
    #   /etc/sysconfig/syslog
    #
    #    local2.*                       /var/log/haproxy.log
    #
    log         127.0.0.1 local2

    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    maxconn     4000
    user        haproxy
    group       haproxy
    daemon

    # turn on stats unix socket
    stats socket /var/lib/haproxy/stats

#---------------------------------------------------------------------
# common defaults that all the 'listen' and 'backend' sections will
# use if not designated in their block
#---------------------------------------------------------------------
defaults
    mode                    http
    log                     global
    option                  httplog
    option                  dontlognull
    option http-server-close
    option forwardfor       except 127.0.0.0/8
    option                  redispatch
    retries                 3
    timeout http-request    10s
    timeout queue           1m
    timeout connect         10s
    timeout client          1m
    timeout server          1m
    timeout http-keep-alive 10s
    timeout check           10s
    maxconn                 3000

#---------------------------------------------------------------------
# kubernetes apiserver frontend which proxys to the backends
#---------------------------------------------------------------------
frontend kubernetes-apiserver
    mode                 tcp
    bind                 *:16443
    option               tcplog
    default_backend      kubernetes-apiserver

#---------------------------------------------------------------------
# round robin balancing between the various backends
#---------------------------------------------------------------------
backend kubernetes-apiserver
    mode        tcp
    balance     roundrobin
    server  k8s-master-node0 192.168.11.220:6443 check
    server  k8s-master-node1 192.168.11.221:6443 check
    server  k8s-master-node2 192.168.11.222:6443 check

#---------------------------------------------------------------------
# collection haproxy statistics message
#---------------------------------------------------------------------
listen stats
    bind                 *:1080
    stats auth           admin:awesomePassword
    stats refresh        5s
    stats realm          HAProxy\ Statistics
    stats uri            /admin?stats
```
Таким образом, весь траффик, который идёт на порт 16443 перенаправляется на один из мастер узлов, описанных в конфиге. Неважно, на какой узел приходит запрос - k8s знал, где "главенствующий" master-узел и запрос перенаправляется на выполнение им.  
На каждой управляющей ноде был также установлен keepalived для поддержания VIP. Настройки следующие:
```yaml
! Configuration File for keepalived

global_defs {
   router_id LVS_DEVEL
}

vrrp_script check_haproxy {
    script "killall -0 haproxy"
    interval 3
    weight -2
    fall 10
    rise 2
}

vrrp_instance VI_1 {
    state MASTER # на самом "живучем" узле был выставлен state MASTER, на остальных BACKUP
    interface eth0
    virtual_router_id 51
    priority 250 # уменьшается при переходе к новым узлам
    advert_int 1
    virtual_ipaddress {
        192.168.11.230
    }
    track_script {
        check_haproxy
    }
}
```
VIP поднимает на одном из трёх мастер-узлов виртуальный IP адрес 192.168.11.230. В случае выхода из строя (или недоступности) адреса на MASTER узле - IP  перехватывается и поднимается на другой ноде. Таким образом обеспечивается постоянная доступность VIP. После установки необходимо запустить keepalived (systemctl start keepalived) и настроить автозагрузку (systemctl enable keepalived).   
Кластер инициализируется при помощи команды ``kubeadm init --upload-certs --control-plane-endpoint 192.168.11.230:16443``.  
  
В результате выполнения будут созданы два токена: для джойна мастер-узлов и воркер-узлов. Необходимо выполнить джойн запрос соответствующего типа на соответствующем узле.  
После настройки кластера узлы будут находится в состоянии ``not-ready`` в связи с отсутствием сетевого взаимодействия. Эта проблема решается установкой CNI-плагина. В данной установки был использован ``calico``:
```bash
kubectl create -f https://projectcalico.docs.tigera.io/manifests/tigera-operator.yaml
curl https://projectcalico.docs.tigera.io/manifests/custom-resources.yaml -O
kubectl create -f custom-resources.yaml
```
В результате создаются POD-ы, нужные для работы сетевой части системы:
```bash
[teligent@k8s-master-node0 ~]$ kubectl -n kube-system get po | grep calico
calico-kube-controllers-56fcbf9d6b-44b7p   1/1     Running   
calico-kube-controllers-56fcbf9d6b-4js98   1/1     Running   
calico-kube-controllers-56fcbf9d6b-q9ptt   1/1     Running   
calico-node-66psl                          1/1     Running   
calico-node-bmj7d                          1/1     Running   
calico-node-hpfvh                          1/1     Running   
calico-node-j4x4c                          1/1     Running   
calico-node-j7c8z                          1/1     Running   
calico-node-pxbq2                          1/1     Running   
```
