first line

**/.terraform/* - в директории terraform будут проигнорированы абсолютно все файлы в подкаталогах ./terraform
*.tfstate - будут проигнорированы все файлы с расширением .tfstate
*.tfstate.* - будут проигнорированы все файлы где содержится название *.tfstate.*
crash.log - будет проигнорирован файл crash.log
*.tfvars - будут проигнорированы dct файлы с расширением .tfvars
override.tf - будет проигнорирован файл ovveride.tf
override.tf.json - будет проигнорирован файл override.tf.json
*_override.tf - будут проигнорированы все файлы которые заканчиваются на _override.tf
*_override.tf.json - будет проигнорированы все файлы которые заканчиваются на _override.tf.json
.terraformrc - будет проигнорирован файл .terraformrc
terraform.rc - будет проигнорирован файл terraform.rc
