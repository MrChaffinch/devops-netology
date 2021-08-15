##Задание 3.2

#1
cd - программа командной строки, исходя из сокращения может значить change directory

#2
cat <some_file> | wc -l

#3
vagrant@vagrant:~/test_bulk_creation$ ps aux -p 1 \
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND \
root           1  0.0  1.1 167224 11220 ?        Ss   09:59   0:01 /sbin/init

#4
vagrant@vagrant:~$ ls ./file.txt 2>> /dev/pts/1 \
vagrant@vagrant:~$

vagrant@vagrant:~$ ls: cannot access './file.txt': No such file or directory \

#5
vagrant@vagrant:~$ ls -la > hd_out.txt \
vagrant@vagrant:~$ cat hd_out.txt \
total 8384 \
drwxr-xr-x 6 vagrant vagrant    4096 Aug 15 08:10 . \
drwxr-xr-x 3 root    root       4096 Jul 28 17:50 .. \
-rw------- 1 vagrant vagrant    1464 Aug 13 16:17 .bash_history \ 
-rw-r--r-- 1 vagrant vagrant     220 Jul 28 17:50 .bash_logout \
-rw-r--r-- 1 vagrant vagrant    3771 Jul 28 17:50 .bashrc \
drwx------ 2 vagrant vagrant    4096 Jul 28 17:51 .cache \
-rw------- 1 vagrant vagrant      72 Aug 14 11:36 .lesshst \
drwxrwxr-x 3 vagrant vagrant    4096 Aug 11 19:40 .local \
-rw-r--r-- 1 vagrant vagrant     807 Jul 28 17:50 .profile \
drwx------ 2 vagrant root       4096 Aug  8 18:04 .ssh \
-rw-r--r-- 1 vagrant vagrant       0 Jul 28 17:51 .sudo_as_admin_successful \
-rw-r--r-- 1 vagrant vagrant       6 Jul 28 17:51 .vbox_version \
-rw-r--r-- 1 root    root        180 Jul 28 17:55 .wget-hsts \
-rw-rw-r-- 1 vagrant vagrant       0 Aug 15 08:10 hd_out.txt \
drwxrwxr-x 2 vagrant vagrant 8536064 Aug 14 09:47 test_bulk_creation

#6
tty - сессия терминала непосредственно на самой машине
pty - сессия терминала создаётся при ssh подключении

#7
bash 5>&1 - выполнение данной команды ни к чему не приводит \
echo netology > /proc/$$/fd/5 - данная команда выводит данные echo в текущую сессию

#8

#9
cat /proc/$$/environ - выполняет вывод переменных текущей сессии \
также можно вывести просто написа в консоли: \
vagrant@vagrant:~$ env

#10
/proc/[pid]/cmdline - файл, в котором хранится командная строка, которой был запущен данный процесс \
/proc/[pid]/exe - символьная ссылка на исполняемый файл, который инициировал запуск процесса

#11
Судя по выводу команды это sse версии 4_2 \
vagrant@vagrant:~$ cat /proc/cpuinfo | grep sse \
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ht syscall nx rdtscp lm constant_tsc rep_good nopl xtopology nonstop_tsc cpuid tsc_known_freq pni pclmulqdq ssse3 cx16 pcid sse4_1 sse4_2 x2apic movbe popcnt aes xsave avx rdrand hypervisor lahf_lm abm 3dnowprefetch invpcid_single pti fsgsbase avx2 invpcid rdseed clflushopt md_clear flush_l1d

#12
tty - это локальный инстанс терминала, он не используется для удалённого соединения

#13
с помощью скрин можно создать новый эмулятор терминала в другой bash сессии \
в первом терминале создаём сессию: \
screen -dR test \

во втором подключаемся к ней: \
screen -x test

#14
sudo echo - только выводит значение, которое будет записано \
tee - пишет данное значение в файл, соответственно ей необходимы права рута \

Различие данные команд в том, что echo только выводит значение, а tee переводит stdin в stdout и файлы


