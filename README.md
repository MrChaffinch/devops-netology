##Задание 3.2

#1
cd - команда стандартной bash оболочки, так как это не самостоятельная программа, она работает только в оболочке bash.

#2
grep -c "some_text" "some_file" 

#3
vagrant@vagrant:~$ pstree -p 1 \
systemd(1)─┬─VBoxService(784)─┬─{VBoxService}(785) \
           │                  ├─{VBoxService}(786) \
           │                  ├─{VBoxService}(787) \
           │                  ├─{VBoxService}(788) \
           │                  ├─{VBoxService}(789) \
           │                  ├─{VBoxService}(790) \
           │                  ├─{VBoxService}(791) \
           │                  └─{VBoxService}(792) \
           ├─accounts-daemon(578)─┬─{accounts-daemon}(609) \
           │                      └─{accounts-daemon}(647) \
           ├─agetty(816) \
           ├─atd(806) \
           ├─cron(803) \
           ├─dbus-daemon(579) \
           ├─irqbalance(584)───{irqbalance}(590) \
           ├─multipathd(528)─┬─{multipathd}(529) \
           │                 ├─{multipathd}(530) \
           │                 ├─{multipathd}(531) \
           │                 ├─{multipathd}(532) \
           │                 ├─{multipathd}(533) \
           │                 └─{multipathd}(534) \
           ├─networkd-dispat(585) \
           ├─polkitd(661)─┬─{polkitd}(663) \
           │              └─{polkitd}(665) \
           ├─rpcbind(553) \
           ├─rsyslogd(586)─┬─{rsyslogd}(634) \
           │               ├─{rsyslogd}(635) \
           │               └─{rsyslogd}(636) \
           ├─sshd(805)─┬─sshd(1087)───sshd(1134)───bash(1135)───bash(1643)───pstree(2324) \
           │           └─sshd(1443)───sshd(1483)───bash(1484) \
           ├─systemd(1100)───(sd-pam)(1101) \
           ├─systemd-journal(363) \
           ├─systemd-logind(589) \
           ├─systemd-network(399) \
           ├─systemd-resolve(555) \
           └─systemd-udevd(394) \

#4
vagrant@vagrant:~$ ls /some_folder 2> /dev/pts/1 \

vagrant@vagrant:~$ ls: cannot access '/non_existing_folder': No such file or directory \
ls: cannot access '/non_existing_folder': No such file or directory

#5
vagrant@vagrant:~$ cat < new_file > new_file4 \
vagrant@vagrant:~$ cat new_file4 \
123

#6
tty - сессия терминала непосредственно на самой машине \
pty - сессия терминала создаётся при ssh подключении \

Насколько я понял, в графическом режиме, мы так же можем окрыть терминал и вывести данные из pty в tty.

#7
bash 5>&1 - создание нового файлового дескриптора и перенаправляем поток stdout  \
echo netology > /proc/$$/fd/5 - данная команда выводит данные в новый файловый дискриптор 5 \
vagrant@vagrant:~$ bash 5>&1 \
vagrant@vagrant:~$ echo netology > /proc/$$/fd/5 \
netology \ 
vagrant@vagrant:~$ echo netology > /proc/$$/fd/1 \ 
netology \
vagrant@vagrant:~$ echo netology > /proc/$$/fd/2 \
netology \
vagrant@vagrant:~$ echo netology > /proc/$$/fd/3 \
bash: /proc/2421/fd/3: No such file or directory \
vagrant@vagrant:~$ echo netology > /proc/$$/fd/4 \
bash: /proc/2421/fd/4: No such file or directory

#8
vagrant@vagrant:~$ cat some_file \
cat: some_file: No such file or directory \
vagrant@vagrant:~$ cat some_file 5>&1 1>&2 2>&5 | tee test.txt \
cat: some_file: No such file or directory

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
tty - это локальный инстанс терминала, он не используется для удалённого соединения \
Так как при подключении ssh используется другой физический терминал. \
Из сессии pty нельзя перейти в сессию tty. \
Для корректной отработки команды надо зайти непосредственно локально на саму вм.

#13
Сначала для примера выводим top \
vagrant@vagrant:~$ top \
vagrant@vagrant:~$ jobs -l - смотрим что запущено и его PID \
далее отправляем его в бэкграунд CTRL+Z \

Затем открываем ещё одну сессию, запускаем скрин \
vagrant@vagrant:~$ screen \
vagrant@vagrant:~$ reptyr PID - перехватываем процесс через PID, который мы узнали ранее \

Так же выскакивала ошибка: \
Unable to attach to pid : Operation not permitted \
The kernel denied permission while attaching. If your uid matches \
the target's, check the value of /proc/sys/kernel/yama/ptrace_scope. \
For more information, see /etc/sysctl.d/10-ptrace.conf \

Это связано с правами, с которыми запущено ядро, поэтому после изменения на: \
kernel.yama.ptrace_scope = 0 \
всё заработало.

#14
echo string | sudo tee /root/new_file \
Данная конструкция будет работать, так как: \
Эта конструкция может быть использована для перенаправления в любой каталог, к которому нет доступа. \
Программа tee, в отличии от просто echo (которая просто выводит данные),фактически является программой "echo to a file".
