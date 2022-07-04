# Самоконтроль выполненения задания

1. Где расположен файл с `some_fact` из второго пункта задания?

group_vars/all/examp.yml

2. Какая команда нужна для запуска вашего `playbook` на окружении `test.yml`?

ansible-playbook -i inventory/test.yml site.yml

3. Какой командой можно зашифровать файл?

ansible-vault encrypt path_to_file

4. Какой командой можно расшифровать файл?

ansible-vault decrypt path_to_file

5. Можно ли посмотреть содержимое зашифрованного файла без команды расшифровки файла? Если можно, то как?

Для этого служит команда ``ansible-vault view path_to_encrypted_file``

6. Как выглядит команда запуска `playbook`, если переменные зашифрованы?

ansible-playbook -i path_to_inventory site.yml --ask-vault-password

7. Как называется модуль подключения к host на windows?

Для подключения используется модуль winrm.

8. Приведите полный текст команды для поиска информации в документации ansible для модуля подключений ssh

``ansible-doc -t connection ssh``

9. Какой параметр из модуля подключения `ssh` необходим для того, чтобы определить пользователя, под которым необходимо совершать подключение?

[Ссылка на GitHub репо](https://github.com/ansible/ansible/blob/c600ab81ee/lib/ansible/playbook/play_context.py#L46-L55)  
``remote_user      = ('ansible_ssh_user', 'ansible_user')``