Homework 3.4

#1 
В данном примере добавлена переменная $NODE_PORT, она необходима для старта сервиса на определённом порту. \
Задаётся она в EnvironmentFile=/opt/node_exporter/node_env

vagrant@vagrant:~$ cat /opt/node_exporter/node_env \
[Service] \
NODE_PORT="--web.listen-address=:9100"

{
root@vagrant:~# cat /etc/systemd/system/node_exporter.service \
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=vagrant
EnvironmentFile=/opt/node_exporter/node_env
ExecStart=/opt/node_exporter/node_exporter $NODE_PORT

[Install]
WantedBy=multi-user.target
}

{
root@vagrant:~# systemctl enable node_exporter.service \
Created symlink /etc/systemd/system/multi-user.target.wants/node_exporter.service → /etc/systemd/system/node_exporter.service.
}

{
root@vagrant:~# systemctl status node_exporter.service \
● node_exporter.service - Node Exporter \
     Loaded: loaded (/etc/systemd/system/node_exporter.service; disabled; vendor preset: enabled) \
     Active: active (running) since Mon 2021-08-23 22:01:38 UTC; 21h ago \
   Main PID: 1421 (node_exporter) \
      Tasks: 6 (limit: 1071) \
     Memory: 5.6M \
     CGroup: /system.slice/node_exporter.service \
             └─1421 /opt/node_exporter/node_exporter \

Aug 23 22:01:38 vagrant node_exporter[1421]: level=info ts=2021-08-23T22:01:38.492Z caller=node_exporter.go:115 collector=thermal_zone \
Aug 23 22:01:38 vagrant node_exporter[1421]: level=info ts=2021-08-23T22:01:38.492Z caller=node_exporter.go:115 collector=time \
Aug 23 22:01:38 vagrant node_exporter[1421]: level=info ts=2021-08-23T22:01:38.492Z caller=node_exporter.go:115 collector=timex \
Aug 23 22:01:38 vagrant node_exporter[1421]: level=info ts=2021-08-23T22:01:38.492Z caller=node_exporter.go:115 collector=udp_queues \
Aug 23 22:01:38 vagrant node_exporter[1421]: level=info ts=2021-08-23T22:01:38.492Z caller=node_exporter.go:115 collector=uname \
Aug 23 22:01:38 vagrant node_exporter[1421]: level=info ts=2021-08-23T22:01:38.492Z caller=node_exporter.go:115 collector=vmstat \
Aug 23 22:01:38 vagrant node_exporter[1421]: level=info ts=2021-08-23T22:01:38.492Z caller=node_exporter.go:115 collector=xfs \
Aug 23 22:01:38 vagrant node_exporter[1421]: level=info ts=2021-08-23T22:01:38.492Z caller=node_exporter.go:115 collector=zfs \
Aug 23 22:01:38 vagrant node_exporter[1421]: level=info ts=2021-08-23T22:01:38.492Z caller=node_exporter.go:199 msg="Listening on" address=:9100 \
Aug 23 22:01:38 vagrant node_exporter[1421]: level=info ts=2021-08-23T22:01:38.495Z caller=tls_config.go:191 msg="TLS is disabled." http2=false
}

#2
{
process_cpu_seconds_total \
node_cpu_guest_seconds_total{mode="nice", mode="user"} \
go_memstats_gc_cpu_fraction \
node_cpu_seconds_total{mode="idle"} \
node_cpu_seconds_total{mode="iowait"} \
node_cpu_seconds_total{mode="irq"} \
node_cpu_seconds_total{mode="nice"} \
node_cpu_seconds_total{mode="softirq"} \
node_cpu_seconds_total{mode="steal"} \
node_cpu_seconds_total{mode="system"} \
node_cpu_seconds_total{mode="user"} \
node_disk_io_now \
node_disk_io_time_seconds_total \
node_disk_io_time_weighted_seconds_total \
node_disk_read_time_seconds_total \
node_disk_write_time_seconds_total \
node_memory_MemAvailable_bytes \
node_memory_MemTotal_bytes \
node_memory_Buffers_bytes \
node_memory_Cached_bytes \
node_memory_Slab_bytes \
node_memory_SwapCached_bytes \
node_memory_SwapFree_bytes \
node_memory_SwapTotal_bytes \
node_network_receive_bytes_total \
node_network_receive_drop_total \
node_network_iface_link \
node_network_iface_link_mode \
node_network_mtu_bytes \
node_network_receive_errs_total \
node_network_receive_fifo_total \
node_network_speed_bytes \
node_network_transmit_bytes_total
}

#3
![Alt text](screenshots/Screenshot 2021-08-24 at 23.09.24.png?raw=true "Optional Title")
#4
{
vagrant@vagrant:~$ dmesg | grep DMI \
[    0.000000] DMI: innotek GmbH VirtualBox/VirtualBox, BIOS VirtualBox 12/01/2006 \
[    0.301806] ACPI: Added _OSI(Linux-Lenovo-NV-HDMI-Audio)
}

#5
{
vagrant@vagrant:~$ sysctl -n fs.nr_open \
1048576
}

fs.nr_open - системный лимит на кол-во открытых дескрипторов \

по идее параметр open files (-n) 1024 не даст открыть такое кол-во

#6
Для начала стартанём htop в новом неймспейсе: \
unshare -fp --mount-proc htop.

Найдём через ps aux | grep htop наш процесс: \
Через nsenter -t 11560 -p --mount, откроем новый нэймспейс и посмотрим, какие в нём есть процессы:

{
root@vagrant:/# ps aux \
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND \
root           1  0.0  0.3  10988  3852 pts/1    S+   22:38   0:00 htop \
root           2  0.0  0.3  11560  3780 pts/0    S    22:38   0:00 -bash \
root          11  0.0  0.3  13216  3340 pts/0    R+   22:38   0:00 ps aux
}
#7
:(){ :|:& };: - дословно переводится как "экспоненциально порождает подпроцессы, пока ваш ящик не заблокируется" \
cgroup: fork rejected by pids controller in /user.slice/user-1000.slice/session-3.scope 

{
systemctl cat user-1000.slice \
vagrant@vagrant:~$ systemctl cat user-1000.slice

[Unit] \
Description=User Slice of UID %j \
Documentation=man:user@.service(5) \
After=systemd-user-sessions.service \
StopWhenUnneeded=yes

[Slice] \
TasksMax=33% 
}

