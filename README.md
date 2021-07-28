first line

* **/.terraform/* - в директории terraform будут проигнорированы абсолютно все файлы в подкаталогах ./terraform
* *.tfstate - будут проигнорированы все файлы с расширением .tfstate
* *.tfstate.* - будут проигнорированы все файлы где содержится название *.tfstate.*
* crash.log - будет проигнорирован файл crash.log
* *.tfvars - будут проигнорированы dct файлы с расширением .tfvars
* override.tf - будет проигнорирован файл ovveride.tf
* override.tf.json - будет проигнорирован файл override.tf.json
* *_override.tf - будут проигнорированы все файлы которые заканчиваются на _override.tf
* *_override.tf.json - будет проигнорированы все файлы которые заканчиваются на _override.tf.json
* .terraformrc - будет проигнорирован файл .terraformrc
* terraform.rc - будет проигнорирован файл terraform.rc

#1

* commit aefead2207ef7e2aa5dc81a34aedf0cad4c32545
* Author: Alisdair McDiarmid <alisdair@users.noreply.github.com>
* Date:   Thu Jun 18 10:29:58 2020 -0400
*
*    Update CHANGELOG.md
*
* diff --git a/CHANGELOG.md b/CHANGELOG.md
* index 86d70e3e0..588d807b1 100644
* --- a/CHANGELOG.md
* +++ b/CHANGELOG.md
* @@ -27,6 +27,7 @@ BUG FIXES:
*  * backend/s3: Prefer AWS shared configuration over EC2 metadata credentials by default ([#25134](https://github.com/hashicorp/terraform/issues/25134))
*  * backend/s3: Prefer ECS credentials over EC2 metadata credentials by default ([#25134](https://github.com/hashicorp/terraform/issues/25134))
*  * backend/s3: Remove hardcoded AWS Provider messaging ([#25134](https://github.com/hashicorp/terraform/issues/25134))
* +* command: Fix bug with global `-v`/`-version`/`--version` flags introduced in 0.13.0beta2 [GH-25277]
*  * command/0.13upgrade: Fix `0.13upgrade` usage help text to include options ([#25127](https://github.com/hashicorp/terraform/issues/25127))
*  * command/0.13upgrade: Do not add source for builtin provider ([#25215](https://github.com/hashicorp/terraform/issues/25215))
*  * command/apply: Fix bug which caused Terraform to silently exit on Windows when using absolute plan path ([#25233](https://github.com/hashicorp/terraform/issues/25233))

#2
    
* git describe --exact-match 85024d3
* v0.12.23

#2

* git rev-parse b8d720^@
* 56cd7859e05c36c06b56d013b55a252d0bb7e158
* 9ea88f22fc6269854151c571162c5bcf958bee2b

#4

* git log v0.12.23..v0.12.24
* commit 33ff1c03bb960b332be3af2e333462dde88b279e (tag: v0.12.24)
* Author: tf-release-bot <terraform@hashicorp.com>
* Date:   Thu Mar 19 15:04:05 2020 +0000
*
*    v0.12.24
*
* commit b14b74c4939dcab573326f4e3ee2a62e23e12f89
* Author: Chris Griggs <cgriggs@hashicorp.com>
* Date:   Tue Mar 10 08:59:20 2020 -0700
*
*    [Website] vmc provider links
*
* commit 3f235065b9347a758efadc92295b540ee0a5e26e
* Author: Alisdair McDiarmid <alisdair@users.noreply.github.com>
* Date:   Thu Mar 19 10:39:31 2020 -0400
*
*    Update CHANGELOG.md
*
* commit 6ae64e247b332925b872447e9ce869657281c2bf
* Author: Alisdair McDiarmid <alisdair@users.noreply.github.com>
* Date:   Thu Mar 19 10:20:10 2020 -0400
*
*    registry: Fix panic when server is unreachable
*
*    Non-HTTP errors previously resulted in a panic due to dereferencing the
*    resp pointer while it was nil, as part of rendering the error message.
*    This commit changes the error message formatting to cope with a nil
*    response, and extends test coverage.
*
*    Fixes #24384
*
* commit 5c619ca1baf2e21a155fcdb4c264cc9e24a2a353
* Author: Nick Fagerlund <nick.fagerlund@gmail.com>
* Date:   Wed Mar 18 12:30:20 2020 -0700
*
*    website: Remove links to the getting started guide's old location
*
*    Since these links were in the soon-to-be-deprecated 0.11 language section, I
*    think we can just remove them without needing to find an equivalent link.
*
* commit 06275647e2b53d97d4f0a19a0fec11f6d69820b5
* Author: Alisdair McDiarmid <alisdair@users.noreply.github.com>
* Date:   Wed Mar 18 10:57:06 2020 -0400
*
*    Update CHANGELOG.md
*
* commit d5f9411f5108260320064349b757f55c09bc4b80
* Author: Alisdair McDiarmid <alisdair@users.noreply.github.com>
* Date:   Tue Mar 17 13:21:35 2020 -0400
*
*    command: Fix bug when using terraform login on Windows
*
* commit 4b6d06cc5dcb78af637bbb19c198faff37a066ed
* Author: Pam Selle <pam@hashicorp.com>
* Date:   Tue Mar 10 12:04:50 2020 -0400
*
*    Update CHANGELOG.md
*
* commit dd01a35078f040ca984cdd349f18d0b67e486c35
* Author: Kristin Laemmert <mildwonkey@users.noreply.github.com>
*Date:   Thu Mar 5 16:32:43 2020 -0500
*
*    Update CHANGELOG.md
*
* commit 225466bc3e5f35baa5d07197bbc079345b77525e
* Author: tf-release-bot <terraform@hashicorp.com>
* Date:   Thu Mar 5 21:12:06 2020 +0000
*
*    Cleanup after v0.12.23 release

#5
* git grep --count 'func providerSource'
* provider_source.go:2

* git log -L :providerSource:provider_source.go
* commit 8c928e83589d90a031f811fae52a81be7153e82f

#6

* 78b12205587fe839f10d946ea3fdc06719decb05 Remove config.go and update things using its aliases
* 52dbf94834cb970b510f2fba853a5b49ad9b1a46 keep .terraform.d/plugins for discovery
* 41ab0aef7a0fe030e84018973a64135b11abcd70 Add missing OS_ARCH dir to global plugin paths
* 66ebff90cdfaa6938f26f908c7ebad8d547fea17 move some more plugin search path logic to command
* 8364383c359a6b738a436d1b7745ccdce178df47 Push plugin discovery down into command package

#7

* git log -S"synchronizedWriters" --pretty=format:'%h %an %ad %s'
* bdfea50cc James Bardin Mon Nov 30 18:02:04 2020 -0500 remove unused
* fd4f7eb0b James Bardin Wed Oct 21 13:06:23 2020 -0400 remove prefixed io
* 5ac311e2a Martin Atkins Wed May 3 16:25:41 2017 -0700 main: synchronize writes to VT100-faker on Windows

* Исходя из команды git show 5ac311e2a --oneline

* Мы видим, что автор Martin Atkins