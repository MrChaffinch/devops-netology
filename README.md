#1
bash-3.2$ a=1 \
bash-3.2$ b=2 \
bash-3.2$ c=a+b \
bash-3.2$ d=$a+$b \
bash-3.2$ e=$(($a+$b)) \
bash-3.2$ echo $c \
a+b \
bash-3.2$ echo $d \
1+2 \
bash-3.2$ echo $e \
3 

в случае с переменной $c, мы просто задали строчное значение этой переменной \
в случае с переменной $d, такая же история, символ + является строковым \
в случае с переменной $e, мы задаём, что она =$((сумме переменных a и b))

#2

while ((1==1)) \
do \
curl https://localhost:4757 \
if (($? != 0)) \
then \
date >> curl.log \
else\
break \
fi \
done

Мы добавили условие остановки цикла, а также исправили ошибочный синтаксис

#3

#!bin/bash 
ips=(192.168.0.1 173.194.222.113 87.250.250.242) \
for j in {1..5} \
do \
 for i in ${ips[@]} \
 do \
  curl i \
  date >> curl_task.log \
 done \
done

#4

#!bin/bash
ips=(192.168.0.1 173.194.222.113 87.250.250.242) \
e=1 \
while (True) \
do \
 for i in ${ips[@]} \
 do \
  curl $i \
  if (($?==0)) \
  then \
  echo $i >> curl.log \
  date >> curl.log \
  echo код завершения операции :$? >> curl.log \
  else \
  echo $i >> curl_error.log \
  date >> curl_error.log \
  e=0 \
  fi \
 done \
 if (($e==0)) \
 then \
 break \
 else \
 continue \
 fi \
done
