##Задание 3.1

#1,2,3,4
ilyamarin@Ilyas-MacBook-Pro vagrant % vboxmanage --version \
6.1.26r145957 \
ilyamarin@Ilyas-MacBook-Pro vagrant % vagrant --version \
Vagrant 2.2.18 \
ilyamarin@Ilyas-MacBook-Pro vagrant % vagrant up \
Bringing machine 'default' up with 'virtualbox' provider... \
==> default: Checking if box 'bento/ubuntu-20.04' version '202107.28.0' is up to date... \
==> default: Clearing any previously set forwarded ports... \
==> default: Clearing any previously set network interfaces... \
==> default: Preparing network interfaces based on configuration... \
    default: Adapter 1: nat \
==> default: Forwarding ports... \
    default: 22 (guest) => 2222 (host) (adapter 1) \
==> default: Booting VM... \ 
==> default: Waiting for machine to boot. This may take a few minutes... \
    default: SSH address: 127.0.0.1:2222 \
    default: SSH username: vagrant \
    default: SSH auth method: private key \
    default: Warning: Connection reset. Retrying... \
==> default: Machine booted and ready! \
==> default: Checking for guest additions in VM... \
==> default: Mounting shared folders... \
    default: /vagrant => /Users/ilyamarin/vagrant \
==> default: Machine already provisioned. Run `vagrant provision` or use the `--provision` \
==> default: flag to force provisioning. Provisioners marked to run always will still run. \

#5
Resources by default 1gb RAM, 2 vCPU, 64 gb HDD

#6
config.vm.provider "virtualbox" do |v|
  v.memory = 
  v.cpus = prefered vCPU count
end

#8
vagrant@vagrant:~$ man bash | grep -n HISTSIZE
630:              size.  Non-numeric values and numeric values less than zero inhibit truncation.  The shell sets the default value to the value of HISTSIZE after reading any startup files.
637:       HISTSIZE

ignoreboth - игнорирование дубликатов.

#9
{} - нужны для указания массива или паттерна поиска или же при конструкции ${} ввода какой-либо переменной

#10
touch file{1..100000}

для создания touch file{1..300000}, необходимо увеличить ulimit -s 65536

#11
[[ -d /tmp ]] почитал, при такой конструкции идёт проверка существует ли директория

#12
vagrant@vagrant:~$ mkdir /tmp/new_path_directory \
vagrant@vagrant:~$ touch /tmp/new_path_directory/bash \
vagrant@vagrant:~$ chmod 755 /tmp/new_path_directory/bash \
vagrant@vagrant:~$ type -a bash \
bash is /tmp/new_path_directory/bash \
bash is /usr/bin/bash \
bash is /bin/bash

#13
at - используется для запуска в назначенное время
batch -  выполняет команду только в том случае, если load average опускается ниже 0.8