#!/bin/bash

docker run -d  --name centos7 pycontribs/centos:7 sleep 6000
docker run -d  --name ubuntu pycontribs/ubuntu sleep 6000
docker run -d  --name fedora pycontribs/fedora sleep 6000

ansible-playbook -i inventory/prod.yml site.yml --ask-vault-password

docker container stop centos7 ubuntu fedora