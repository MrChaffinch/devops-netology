Homework 3.3

#1
strace /bin/bash -c 'cd /tmp' 

chdir("/tmp")

#2
/usr/share/misc/magic 
/usr/share/misc/magic.mgc 

Во всех выводах присутсутют данные строчки, в man file, сказано, что для проверки и тестрования используется magic файл.

#3

vagrant@vagrant:~$ lsof | grep vboxadd-setup.log.4 \
lsof: WARNING: can't stat() tracefs file system /sys/kernel/debug/tracing \
      Output information may be incomplete. \
tail      1888                        vagrant    3r      REG              253,0       61    1441843 /var/log/vboxadd-setup.log.4 (deleted) \

Выводим данные по файлу, а именно PID и его дескриптор


vagrant@vagrant:~$ ls -l /proc/1888/fd/3 \
lr-x------ 1 vagrant vagrant 64 Aug 20 20:02 /proc/1888/fd/3 -> '/var/log/vboxadd-setup.log.4 (deleted)' \


Далее файлу необходимо сделать truncate: 


vagrant@vagrant:~$ sudo su \
root@vagrant:/home/vagrant# : > /proc/1888/fd/3 vboxadd-setup.log.4 \
root@vagrant:/home/vagrant# tail: /var/log/vboxadd-setup.log.4: file truncated \


#4
Нет, зомби-процессы не используют системные ресурсы. \
Они могут занять идентификаторы процессов, что в свою очередь может предотвратить запуск новых.

#5

vagrant@vagrant:~$ sudo /usr/sbin/opensnoop-bpfcc \
PID    COMM               FD ERR PATH \
794    vminfo              4   0 /var/run/utmp \
578    dbus-daemon        -1   2 /usr/local/share/dbus-1/system-services \
578    dbus-daemon        18   0 /usr/share/dbus-1/system-services \
578    dbus-daemon        -1   2 /lib/dbus-1/system-services \
578    dbus-daemon        18   0 /var/lib/snapd/dbus-1/system-services 


#6
cat /proc/sys/kernel/{ostype, hostname, osrelease, version, domainname} 

#7
; используется для разделения команд, соответственно завершается одна (даже если она с ошибкой) и начинается дургая. \
«&&» используется для объединения команд таким образом, что следующая команда запускается тогда и только тогда, когда предыдущая команда завершилась без ошибок.

#8
set -euxo pipefail \
-e \
Немедленно завершите работу, если pipe, который может состоять из одной простой команды или списка команд, возвращает ненулевое состояние. \
-o \
через данную опцию мы задаём, параметр который мы хотим задать, в данном случае pipefail \
-u \
данный флаг нужен для попытки использования неопределенной переменной и выводит сообщение об ошибке в stderr и принудительно завершает работу. \
-x \
Выводит каждую команду в stdout, прежде чем её выполнять в расширенном виде

#9
Самый частно встречающийся статус это I< 

К заглавным буквам статуса процесса добавляются доп информация о них: \
< высокий приоритет \
N с низким приоритетом \
L имеет страницы, заблокированные в памяти \
s - лидер сеанса \
l - многопоточный \
(+) - находится в группе процессов переднего плана 