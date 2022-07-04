# Домашнее задание к занятию "08.03 Использование Yandex Cloud"

## Основная часть

1. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает kibana.
2. При создании tasks рекомендую использовать модули: `get_url`, `template`, `yum`, `apt`.
3. Tasks должны: скачать нужной версии дистрибутив, выполнить распаковку в выбранную директорию, сгенерировать конфигурацию с параметрами.
    
    - `playbook.yml`
        ```yml
        ---
        ...
        - name: Install Kibana
        hosts: kibana
        handlers:
            - name: restart Kibana
            become: true
            service:
                name: kibana
                state: restarted
            tags: kibana
        tasks:
            - name: "Download Kibana's rpm"
            get_url:
                url: "https://artifacts.elastic.co/downloads/kibana/kibana-{{ elk_stack_version }}-x86_64.rpm"
                dest: "/tmp/kibana-{{ elk_stack_version }}-x86_64.rpm"
            register: download_kibana
            until: download_kibana is succeeded
            tags: kibana
            - name: Install Kibana
            become: true
            yum:
                name: "/tmp/kibana-{{ elk_stack_version }}-x86_64.rpm"
                state: present
            tags: kibana
            - name: Configure Kibana
            become: true
            template:
                src: kibana.yml.j2
                dest: /etc/kibana/kibana.yml
            notify: restart Kibana
            tags: kibana
        ```
    - `templates/kibana.yml.j2`
        ```yml
        server.host: 0.0.0.0
        elasticsearch.hosts: ["http://{{ hostvars['el-instance']['ansible_facts']['default_ipv4']['address'] }}:9200/"]
        kibana.index: ".kibana"
        ```
4. Приготовьте свой собственный inventory файл `prod.yml`.
    `inventory/prod/hosts.yml`
    ```yml
    ---
    all:
      hosts:
        ...
        k-instance:
          ansible_host: 62.84.127.53
        ...
    kibana:
      hosts:
        k-instance:
    ```
5. Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.
    ```diff
    --- a/playbook.yml
    +++ b/playbook.yml
    @@ -27,12 +27,14 @@
        template:
            src: elasticsearch.yml.j2
            dest: /etc/elasticsearch/elasticsearch.yml
    +        mode: 0644
        tags: elastic
        - name: Configure Elastic JVM
        become: true
        template:
            src: elasticsearch_sysconfig.j2
            dest: /etc/sysconfig/elasticsearch
    +        mode: 0644
        notify: restart Elasticsearch
        tags: elastic
        - name: Install Kibana
    @@ -63,5 +65,6 @@
        template:
            src: kibana.yml.j2
            dest: /etc/kibana/kibana.yml
    +        mode: 0644
        notify: restart Kibana
        tags: kibana
    ```
6. Попробуйте запустить playbook на этом окружении с флагом `--check`.
    ```log
    $ ansible-playbook -i inventory/prod playbook.yml --check

    PLAY [Install Elasticsearch] **************************************************************************************

    TASK [Gathering Facts] ********************************************************************************************
    ok: [el-instance]

    TASK [Download Elasticsearch's rpm] *******************************************************************************
    changed: [el-instance]

    TASK [Install Elasticsearch] **************************************************************************************
    fatal: [el-instance]: FAILED! => {"changed": false, "msg": "No RPM file matching '/tmp/elasticsearch-7.14.0-x86_64.rpm' found on system", "rc": 127, "results": ["No RPM file matching '/tmp/elasticsearch-7.14.0-x86_64.rpm' found on system"]}

    PLAY RECAP ********************************************************************************************************
    el-instance                : ok=2    changed=1    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0
    ```
7. Запустите playbook на `prod.yml` окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.
    
    <details><summary>Полный вывод ansible</summary>

    ```log
    PLAY [Install Elasticsearch] **************************************************************************************

    TASK [Gathering Facts] ********************************************************************************************
    ok: [el-instance]

    TASK [Download Elasticsearch's rpm] *******************************************************************************
    changed: [el-instance]

    TASK [Install Elasticsearch] **************************************************************************************
    changed: [el-instance]

    TASK [Configure Elasticsearch] ************************************************************************************
    --- before: /etc/elasticsearch/elasticsearch.yml
    +++ after: /home/sergey/.ansible/tmp/ansible-local-48194pwd_mstj/tmpnadd2z4p/elasticsearch.yml.j2
    @@ -1,82 +1,7 @@
    -# ======================== Elasticsearch Configuration =========================
    -#
    -# NOTE: Elasticsearch comes with reasonable defaults for most settings.
    -#       Before you set out to tweak and tune the configuration, make sure you
    -#       understand what are you trying to accomplish and the consequences.
    -#
    -# The primary way of configuring a node is via this file. This template lists
    -# the most important settings you may want to configure for a production cluster.
    -#
    -# Please consult the documentation for further information on configuration options:
    -# https://www.elastic.co/guide/en/elasticsearch/reference/index.html
    -#
    -# ---------------------------------- Cluster -----------------------------------
    -#
    -# Use a descriptive name for your cluster:
    -#
    -#cluster.name: my-application
    -#
    -# ------------------------------------ Node ------------------------------------
    -#
    -# Use a descriptive name for the node:
    -#
    -#node.name: node-1
    -#
    -# Add custom attributes to the node:
    -#
    -#node.attr.rack: r1
    -#
    -# ----------------------------------- Paths ------------------------------------
    -#
    -# Path to directory where to store the data (separate multiple locations by comma):
    -#
    path.data: /var/lib/elasticsearch
    -#
    -# Path to log files:
    -#
    path.logs: /var/log/elasticsearch
    -#
    -# ----------------------------------- Memory -----------------------------------
    -#
    -# Lock the memory on startup:
    -#
    -#bootstrap.memory_lock: true
    -#
    -# Make sure that the heap size is set to about half the memory available
    -# on the system and that the owner of the process is allowed to use this
    -# limit.
    -#
    -# Elasticsearch performs poorly when the system is swapping the memory.
    -#
    -# ---------------------------------- Network -----------------------------------
    -#
    -# By default Elasticsearch is only accessible on localhost. Set a different
    -# address here to expose this node on the network:
    -#
    -#network.host: 192.168.0.1
    -#
    -# By default Elasticsearch listens for HTTP traffic on the first free port it
    -# finds starting at 9200. Set a specific HTTP port here:
    -#
    -#http.port: 9200
    -#
    -# For more information, consult the network module documentation.
    -#
    -# --------------------------------- Discovery ----------------------------------
    -#
    -# Pass an initial list of hosts to perform discovery when this node is started:
    -# The default list of hosts is ["127.0.0.1", "[::1]"]
    -#
    -#discovery.seed_hosts: ["host1", "host2"]
    -#
    -# Bootstrap the cluster using an initial set of master-eligible nodes:
    -#
    -#cluster.initial_master_nodes: ["node-1", "node-2"]
    -#
    -# For more information, consult the discovery and cluster formation module documentation.
    -#
    -# ---------------------------------- Various -----------------------------------
    -#
    -# Require explicit names when deleting indices:
    -#
    -#action.destructive_requires_name: true
    +network.host: 0.0.0.0
    +discovery.seed_hosts: ["10.2.0.14"]
    +node.name: node-a
    +cluster.initial_master_nodes:
    +   - node-a

    changed: [el-instance]

    TASK [Configure Elastic JVM] **************************************************************************************
    --- before: /etc/sysconfig/elasticsearch
    +++ after: /home/sergey/.ansible/tmp/ansible-local-48194pwd_mstj/tmpzfwboztl/elasticsearch_sysconfig.j2
    @@ -1,52 +1,3 @@
    -################################
    -# Elasticsearch
    -################################
    -
    -# Elasticsearch home directory
    -#ES_HOME=/usr/share/elasticsearch
    -
    -# Elasticsearch Java path
    -#ES_JAVA_HOME=
    -
    -# Elasticsearch configuration directory
    -# Note: this setting will be shared with command-line tools
    ES_PATH_CONF=/etc/elasticsearch
    -
    -# Elasticsearch PID directory
    -#PID_DIR=/var/run/elasticsearch
    -
    -# Additional Java OPTS
    -#ES_JAVA_OPTS=
    -
    -# Configure restart on package upgrade (true, every other setting will lead to not restarting)
    -#RESTART_ON_UPGRADE=true
    -
    -################################
    -# Elasticsearch service
    -################################
    -
    -# SysV init.d
    -#
    -# The number of seconds to wait before checking if Elasticsearch started successfully as a daemon process
    ES_STARTUP_SLEEP_TIME=5
    -
    -################################
    -# System properties
    -################################
    -
    -# Specifies the maximum file descriptor number that can be opened by this process
    -# When using Systemd, this setting is ignored and the LimitNOFILE defined in
    -# /usr/lib/systemd/system/elasticsearch.service takes precedence
    -#MAX_OPEN_FILES=65535
    -
    -# The maximum number of bytes of memory that may be locked into RAM
    -# Set to "unlimited" if you use the 'bootstrap.memory_lock: true' option
    -# in elasticsearch.yml.
    -# When using systemd, LimitMEMLOCK must be set in a unit file such as
    -# /etc/systemd/system/elasticsearch.service.d/override.conf.
    -#MAX_LOCKED_MEMORY=unlimited
    -
    -# Maximum number of VMA (Virtual Memory Areas) a process can own
    -# When using Systemd, this setting is ignored and the 'vm.max_map_count'
    -# property is set at boot time in /usr/lib/sysctl.d/elasticsearch.conf
    -#MAX_MAP_COUNT=262144
    +ES_JAVA_OPTS="-Xms256m -Xmx256m"

    changed: [el-instance]

    RUNNING HANDLER [restart Elasticsearch] ***************************************************************************
    changed: [el-instance]

    PLAY [Install Kibana] *********************************************************************************************

    TASK [Gathering Facts] ********************************************************************************************
    ok: [k-instance]

    TASK [Download Kibana's rpm] **************************************************************************************
    changed: [k-instance]

    TASK [Install Kibana] *********************************************************************************************
    changed: [k-instance]

    TASK [Configure Kibana] *******************************************************************************************
    --- before: /etc/kibana/kibana.yml
    +++ after: /home/sergey/.ansible/tmp/ansible-local-48194pwd_mstj/tmpzehdh_9j/kibana.yml.j2
    @@ -1,111 +1,3 @@
    -# Kibana is served by a back end server. This setting specifies the port to use.
    -#server.port: 5601
    -
    -# Specifies the address to which the Kibana server will bind. IP addresses and host names are both valid values.
    -# The default is 'localhost', which usually means remote machines will not be able to connect.
    -# To allow connections from remote users, set this parameter to a non-loopback address.
    -#server.host: "localhost"
    -
    -# Enables you to specify a path to mount Kibana at if you are running behind a proxy.
    -# Use the `server.rewriteBasePath` setting to tell Kibana if it should remove the basePath
    -# from requests it receives, and to prevent a deprecation warning at startup.
    -# This setting cannot end in a slash.
    -#server.basePath: ""
    -
    -# Specifies whether Kibana should rewrite requests that are prefixed with
    -# `server.basePath` or require that they are rewritten by your reverse proxy.
    -# This setting was effectively always `false` before Kibana 6.3 and will
    -# default to `true` starting in Kibana 7.0.
    -#server.rewriteBasePath: false
    -
    -# Specifies the public URL at which Kibana is available for end users. If
    -# `server.basePath` is configured this URL should end with the same basePath.
    -#server.publicBaseUrl: ""
    -
    -# The maximum payload size in bytes for incoming server requests.
    -#server.maxPayload: 1048576
    -
    -# The Kibana server's name.  This is used for display purposes.
    -#server.name: "your-hostname"
    -
    -# The URLs of the Elasticsearch instances to use for all your queries.
    -#elasticsearch.hosts: ["http://localhost:9200"]
    -
    -# Kibana uses an index in Elasticsearch to store saved searches, visualizations and
    -# dashboards. Kibana creates a new index if the index doesn't already exist.
    -#kibana.index: ".kibana"
    -
    -# The default application to load.
    -#kibana.defaultAppId: "home"
    -
    -# If your Elasticsearch is protected with basic authentication, these settings provide
    -# the username and password that the Kibana server uses to perform maintenance on the Kibana
    -# index at startup. Your Kibana users still need to authenticate with Elasticsearch, which
    -# is proxied through the Kibana server.
    -#elasticsearch.username: "kibana_system"
    -#elasticsearch.password: "pass"
    -
    -# Enables SSL and paths to the PEM-format SSL certificate and SSL key files, respectively.
    -# These settings enable SSL for outgoing requests from the Kibana server to the browser.
    -#server.ssl.enabled: false
    -#server.ssl.certificate: /path/to/your/server.crt
    -#server.ssl.key: /path/to/your/server.key
    -
    -# Optional settings that provide the paths to the PEM-format SSL certificate and key files.
    -# These files are used to verify the identity of Kibana to Elasticsearch and are required when
    -# xpack.security.http.ssl.client_authentication in Elasticsearch is set to required.
    -#elasticsearch.ssl.certificate: /path/to/your/client.crt
    -#elasticsearch.ssl.key: /path/to/your/client.key
    -
    -# Optional setting that enables you to specify a path to the PEM file for the certificate
    -# authority for your Elasticsearch instance.
    -#elasticsearch.ssl.certificateAuthorities: [ "/path/to/your/CA.pem" ]
    -
    -# To disregard the validity of SSL certificates, change this setting's value to 'none'.
    -#elasticsearch.ssl.verificationMode: full
    -
    -# Time in milliseconds to wait for Elasticsearch to respond to pings. Defaults to the value of
    -# the elasticsearch.requestTimeout setting.
    -#elasticsearch.pingTimeout: 1500
    -
    -# Time in milliseconds to wait for responses from the back end or Elasticsearch. This value
    -# must be a positive integer.
    -#elasticsearch.requestTimeout: 30000
    -
    -# List of Kibana client-side headers to send to Elasticsearch. To send *no* client-side
    -# headers, set this value to [] (an empty list).
    -#elasticsearch.requestHeadersWhitelist: [ authorization ]
    -
    -# Header names and values that are sent to Elasticsearch. Any custom headers cannot be overwritten
    -# by client-side headers, regardless of the elasticsearch.requestHeadersWhitelist configuration.
    -#elasticsearch.customHeaders: {}
    -
    -# Time in milliseconds for Elasticsearch to wait for responses from shards. Set to 0 to disable.
    -#elasticsearch.shardTimeout: 30000
    -
    -# Logs queries sent to Elasticsearch. Requires logging.verbose set to true.
    -#elasticsearch.logQueries: false
    -
    -# Specifies the path where Kibana creates the process ID file.
    -#pid.file: /run/kibana/kibana.pid
    -
    -# Enables you to specify a file where Kibana stores log output.
    -#logging.dest: stdout
    -
    -# Set the value of this setting to true to suppress all logging output.
    -#logging.silent: false
    -
    -# Set the value of this setting to true to suppress all logging output other than error messages.
    -#logging.quiet: false
    -
    -# Set the value of this setting to true to log all events, including system usage information
    -# and all requests.
    -#logging.verbose: false
    -
    -# Set the interval in milliseconds to sample system and process performance
    -# metrics. Minimum is 100ms. Defaults to 5000.
    -#ops.interval: 5000
    -
    -# Specifies locale to be used for all localizable strings, dates and number formats.
    -# Supported languages are the following: English - en , by default , Chinese - zh-CN .
    -#i18n.locale: "en"
    +server.host: 0.0.0.0
    +elasticsearch.hosts: ["http://10.2.0.14:9200/"]
    +kibana.index: ".kibana"
    \ No newline at end of file

    changed: [k-instance]

    RUNNING HANDLER [restart Kibana] **********************************************************************************
    changed: [k-instance]

    PLAY RECAP ********************************************************************************************************
    el-instance                : ok=6    changed=5    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

    k-instance                 : ok=5    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
    ```
    </details>

    Итог:
    ```log
    ...
    PLAY RECAP ********************************************************************************************************
    el-instance                : ok=6    changed=5    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

    k-instance                 : ok=5    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
    ```

8. Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.
    ```log
    PLAY [Install Elasticsearch] **************************************************************************************

    TASK [Gathering Facts] ********************************************************************************************
    ok: [el-instance]

    TASK [Download Elasticsearch's rpm] *******************************************************************************
    ok: [el-instance]

    TASK [Install Elasticsearch] **************************************************************************************
    ok: [el-instance]

    TASK [Configure Elasticsearch] ************************************************************************************
    ok: [el-instance]

    TASK [Configure Elastic JVM] **************************************************************************************
    ok: [el-instance]

    PLAY [Install Kibana] *********************************************************************************************

    TASK [Gathering Facts] ********************************************************************************************
    ok: [k-instance]

    TASK [Download Kibana's rpm] **************************************************************************************
    ok: [k-instance]

    TASK [Install Kibana] *********************************************************************************************
    ok: [k-instance]

    TASK [Configure Kibana] *******************************************************************************************
    ok: [k-instance]

    PLAY RECAP ********************************************************************************************************
    el-instance                : ok=5    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

    k-instance                 : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
    ```
9. Проделайте шаги с 1 до 8 для создания ещё одного play, который устанавливает и настраивает filebeat.
    - `playbook.yml`
        ```yml
        - name: Install Filebeat
        hosts: filebeat
        handlers:
            - name: restart Filebeat
            become: true
            service:
                name: filebeat
                state: restarted
            tags: filebeat
        tasks:
            - name: "Download Filebeat's rpm"
            get_url:
                url: "https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-{{ elk_stack_version }}-x86_64.rpm"
                dest: "/tmp/filebeat-{{ elk_stack_version }}-x86_64.rpm"
            register: download_filebeat
            until: download_filebeat is succeeded
            tags: filebeat
            - name: Install Filebeat
            become: true
            yum:
                name: "/tmp/filebeat-{{ elk_stack_version }}-x86_64.rpm"
                state: present
            tags: filebeat
            - name: Configure Filebeat
            become: true
            template:
                src: filebeat.yml.j2
                dest: /etc/filebeat/filebeat.yml
                mode: 0644
            notify: restart Filebeat
            tags: filebeat
            - name: Enable and configure the system module
            become: true
            command:
                cmd: filebeat modules enable system
                chdir: /usr/share/filebeat/bin
            register: filebeat_modules
            changed_when: filebeat_modules.stdout != 'Module system is already enabled'
            tags: filebeat
            - name: Load Kibana dashboards
            become: true
            command:
                cmd: filebeat setup
                chdir: /usr/share/filebeat/bin
            register: filebeat_setup
            notify: restart Filebeat
            changed_when: false
            until: filebeat_setup is succeeded
            delay: 40
            tags: filebeat
        ```
    - `templates/filebeat.yml.j2`
        ```yml
        filebeat.inputs:
        - type: log
        enabled: false
        paths:
            - /var/log/*.log
        - type: filestream
        enabled: false
        paths:
            - /var/log/*.log
        filebeat.config.modules:
        path: ${path.config}/modules.d/*.yml
        reload.enabled: false
        setup.template.settings:
        index.number_of_shards: 1
        setup.kibana:
        host: "http://{{ hostvars['k-instance']['ansible_facts']['default_ipv4']['address'] }}:5601"
        output.elasticsearch:
        hosts: ["http://{{ hostvars['el-instance']['ansible_facts']['default_ipv4']['address'] }}:9200/"]
        username: "admin"
        password: "elasticadmin"
        processors:
        - add_host_metadata:
            when.not.contains.tags: forwarded
        - add_cloud_metadata: ~
        - add_docker_metadata: ~
        - add_kubernetes_metadata: ~
        ```
    - `inventory/prod/hosts.yml`
        ```yml
        ---
        all:
        hosts:
        ...
            fb-instance:
            ansible_host: 51.250.9.129
        ...
        filebeat:
        hosts:
            fb-instance:
        ```
    - `ansible-playbook -i inventory/prod playbook.yml --diff`

        <details><summary>Полный вывод ansible</summary>

        ```diff
        PLAY [Install Elasticsearch] ***************************************************************************************

        TASK [Gathering Facts] *********************************************************************************************
        ok: [el-instance]

        TASK [Download Elasticsearch's rpm] ********************************************************************************
        ok: [el-instance]

        TASK [Install Elasticsearch] ***************************************************************************************
        ok: [el-instance]

        TASK [Configure Elasticsearch] *************************************************************************************
        ok: [el-instance]

        TASK [Configure Elastic JVM] ***************************************************************************************
        ok: [el-instance]

        PLAY [Install Kibana] **********************************************************************************************

        TASK [Gathering Facts] *********************************************************************************************
        ok: [k-instance]

        TASK [Download Kibana's rpm] ***************************************************************************************
        ok: [k-instance]

        TASK [Install Kibana] **********************************************************************************************
        ok: [k-instance]

        TASK [Configure Kibana] ********************************************************************************************
        ok: [k-instance]

        PLAY [Install Filebeat] ********************************************************************************************

        TASK [Gathering Facts] *********************************************************************************************
        ok: [fb-instance]

        TASK [Download Filebeat's rpm] *************************************************************************************
        changed: [fb-instance]

        TASK [Install Filebeat] ********************************************************************************************
        changed: [fb-instance]

        TASK [Configure Filebeat] ******************************************************************************************
        --- before: /etc/filebeat/filebeat.yml
        +++ after: /home/sergey/.ansible/tmp/ansible-local-49711ib5z3lkr/tmpf36t6y5z/filebeat.yml.j2
        @@ -1,270 +1,26 @@
        -###################### Filebeat Configuration Example #########################
        -
        -# This file is an example configuration file highlighting only the most common
        -# options. The filebeat.reference.yml file from the same directory contains all the
        -# supported options with more comments. You can use it as a reference.
        -#
        -# You can find the full configuration reference here:
        -# https://www.elastic.co/guide/en/beats/filebeat/index.html
        -
        -# For more available modules and options, please see the filebeat.reference.yml sample
        -# configuration file.
        -
        -# ============================== Filebeat inputs ===============================
        -
        filebeat.inputs:
        -
        -# Each - is an input. Most options can be set at the input level, so
        -# you can use different inputs for various configurations.
        -# Below are the input specific configurations.
        -
        - type: log
        -
        -  # Change to true to enable this input configuration.
        enabled: false
        -
        -  # Paths that should be crawled and fetched. Glob based paths.
        paths:
            - /var/log/*.log
        -    #- c:\programdata\elasticsearch\logs\*
        -
        -  # Exclude lines. A list of regular expressions to match. It drops the lines that are
        -  # matching any regular expression from the list.
        -  #exclude_lines: ['^DBG']
        -
        -  # Include lines. A list of regular expressions to match. It exports the lines that are
        -  # matching any regular expression from the list.
        -  #include_lines: ['^ERR', '^WARN']
        -
        -  # Exclude files. A list of regular expressions to match. Filebeat drops the files that
        -  # are matching any regular expression from the list. By default, no files are dropped.
        -  #exclude_files: ['.gz$']
        -
        -  # Optional additional fields. These fields can be freely picked
        -  # to add additional information to the crawled log files for filtering
        -  #fields:
        -  #  level: debug
        -  #  review: 1
        -
        -  ### Multiline options
        -
        -  # Multiline can be used for log messages spanning multiple lines. This is common
        -  # for Java Stack Traces or C-Line Continuation
        -
        -  # The regexp Pattern that has to be matched. The example pattern matches all lines starting with [
        -  #multiline.pattern: ^\[
        -
        -  # Defines if the pattern set under pattern should be negated or not. Default is false.
        -  #multiline.negate: false
        -
        -  # Match can be set to "after" or "before". It is used to define if lines should be append to a pattern
        -  # that was (not) matched before or after or as long as a pattern is not matched based on negate.
        -  # Note: After is the equivalent to previous and before is the equivalent to to next in Logstash
        -  #multiline.match: after
        -
        -# filestream is an input for collecting log messages from files. It is going to replace log input in the future.
        - type: filestream
        -
        -  # Change to true to enable this input configuration.
        enabled: false
        -
        -  # Paths that should be crawled and fetched. Glob based paths.
        paths:
            - /var/log/*.log
        -    #- c:\programdata\elasticsearch\logs\*
        -
        -  # Exclude lines. A list of regular expressions to match. It drops the lines that are
        -  # matching any regular expression from the list.
        -  #exclude_lines: ['^DBG']
        -
        -  # Include lines. A list of regular expressions to match. It exports the lines that are
        -  # matching any regular expression from the list.
        -  #include_lines: ['^ERR', '^WARN']
        -
        -  # Exclude files. A list of regular expressions to match. Filebeat drops the files that
        -  # are matching any regular expression from the list. By default, no files are dropped.
        -  #prospector.scanner.exclude_files: ['.gz$']
        -
        -  # Optional additional fields. These fields can be freely picked
        -  # to add additional information to the crawled log files for filtering
        -  #fields:
        -  #  level: debug
        -  #  review: 1
        -
        -# ============================== Filebeat modules ==============================
        -
        filebeat.config.modules:
        -  # Glob pattern for configuration loading
        path: ${path.config}/modules.d/*.yml
        -
        -  # Set to true to enable config reloading
        reload.enabled: false
        -
        -  # Period on which files under path should be checked for changes
        -  #reload.period: 10s
        -
        -# ======================= Elasticsearch template setting =======================
        -
        setup.template.settings:
        index.number_of_shards: 1
        -  #index.codec: best_compression
        -  #_source.enabled: false
        -
        -
        -# ================================== General ===================================
        -
        -# The name of the shipper that publishes the network data. It can be used to group
        -# all the transactions sent by a single shipper in the web interface.
        -#name:
        -
        -# The tags of the shipper are included in their own field with each
        -# transaction published.
        -#tags: ["service-X", "web-tier"]
        -
        -# Optional fields that you can specify to add additional information to the
        -# output.
        -#fields:
        -#  env: staging
        -
        -# ================================= Dashboards =================================
        -# These settings control loading the sample dashboards to the Kibana index. Loading
        -# the dashboards is disabled by default and can be enabled either by setting the
        -# options here or by using the `setup` command.
        -#setup.dashboards.enabled: false
        -
        -# The URL from where to download the dashboards archive. By default this URL
        -# has a value which is computed based on the Beat name and version. For released
        -# versions, this URL points to the dashboard archive on the artifacts.elastic.co
        -# website.
        -#setup.dashboards.url:
        -
        -# =================================== Kibana ===================================
        -
        -# Starting with Beats version 6.0.0, the dashboards are loaded via the Kibana API.
        -# This requires a Kibana endpoint configuration.
        setup.kibana:
        -
        -  # Kibana Host
        -  # Scheme and port can be left out and will be set to the default (http and 5601)
        -  # In case you specify and additional path, the scheme is required: http://localhost:5601/path
        -  # IPv6 addresses should always be defined as: https://[2001:db8::1]:5601
        -  #host: "localhost:5601"
        -
        -  # Kibana Space ID
        -  # ID of the Kibana Space into which the dashboards should be loaded. By default,
        -  # the Default Space will be used.
        -  #space.id:
        -
        -# =============================== Elastic Cloud ================================
        -
        -# These settings simplify using Filebeat with the Elastic Cloud (https://cloud.elastic.co/).
        -
        -# The cloud.id setting overwrites the `output.elasticsearch.hosts` and
        -# `setup.kibana.host` options.
        -# You can find the `cloud.id` in the Elastic Cloud web UI.
        -#cloud.id:
        -
        -# The cloud.auth setting overwrites the `output.elasticsearch.username` and
        -# `output.elasticsearch.password` settings. The format is `<user>:<pass>`.
        -#cloud.auth:
        -
        -# ================================== Outputs ===================================
        -
        -# Configure what output to use when sending the data collected by the beat.
        -
        -# ---------------------------- Elasticsearch Output ----------------------------
        +  host: "http://10.2.0.6:5601"
        output.elasticsearch:
        -  # Array of hosts to connect to.
        -  hosts: ["localhost:9200"]
        -
        -  # Protocol - either `http` (default) or `https`.
        -  #protocol: "https"
        -
        -  # Authentication credentials - either API key or username/password.
        -  #api_key: "id:api_key"
        -  #username: "elastic"
        -  #password: "changeme"
        -
        -# ------------------------------ Logstash Output -------------------------------
        -#output.logstash:
        -  # The Logstash hosts
        -  #hosts: ["localhost:5044"]
        -
        -  # Optional SSL. By default is off.
        -  # List of root certificates for HTTPS server verifications
        -  #ssl.certificate_authorities: ["/etc/pki/root/ca.pem"]
        -
        -  # Certificate for SSL client authentication
        -  #ssl.certificate: "/etc/pki/client/cert.pem"
        -
        -  # Client Certificate Key
        -  #ssl.key: "/etc/pki/client/cert.key"
        -
        -# ================================= Processors =================================
        +  hosts: ["http://10.2.0.19:9200/"]
        +  username: "admin"
        +  password: "elasticadmin"
        processors:
        - add_host_metadata:
            when.not.contains.tags: forwarded
        - add_cloud_metadata: ~
        - add_docker_metadata: ~
        - add_kubernetes_metadata: ~
        -
        -# ================================== Logging ===================================
        -
        -# Sets log level. The default log level is info.
        -# Available log levels are: error, warning, info, debug
        -#logging.level: debug
        -
        -# At debug level, you can selectively enable logging only for some components.
        -# To enable all selectors use ["*"]. Examples of other selectors are "beat",
        -# "publisher", "service".
        -#logging.selectors: ["*"]
        -
        -# ============================= X-Pack Monitoring ==============================
        -# Filebeat can export internal metrics to a central Elasticsearch monitoring
        -# cluster.  This requires xpack monitoring to be enabled in Elasticsearch.  The
        -# reporting is disabled by default.
        -
        -# Set to true to enable the monitoring reporter.
        -#monitoring.enabled: false
        -
        -# Sets the UUID of the Elasticsearch cluster under which monitoring data for this
        -# Filebeat instance will appear in the Stack Monitoring UI. If output.elasticsearch
        -# is enabled, the UUID is derived from the Elasticsearch cluster referenced by output.elasticsearch.
        -#monitoring.cluster_uuid:
        -
        -# Uncomment to send the metrics to Elasticsearch. Most settings from the
        -# Elasticsearch output are accepted here as well.
        -# Note that the settings should point to your Elasticsearch *monitoring* cluster.
        -# Any setting that is not set is automatically inherited from the Elasticsearch
        -# output configuration, so if you have the Elasticsearch output configured such
        -# that it is pointing to your Elasticsearch monitoring cluster, you can simply
        -# uncomment the following line.
        -#monitoring.elasticsearch:
        -
        -# ============================== Instrumentation ===============================
        -
        -# Instrumentation support for the filebeat.
        -#instrumentation:
        -    # Set to true to enable instrumentation of filebeat.
        -    #enabled: false
        -
        -    # Environment in which filebeat is running on (eg: staging, production, etc.)
        -    #environment: ""
        -
        -    # APM Server hosts to report instrumentation results to.
        -    #hosts:
        -    #  - http://localhost:8200
        -
        -    # API Key for the APM Server(s).
        -    # If api_key is set then secret_token will be ignored.
        -    #api_key:
        -
        -    # Secret token for the APM Server(s).
        -    #secret_token:
        -
        -
        -# ================================= Migration ==================================
        -
        -# This allows to enable 6.7 migration aliases
        -#migration.6_to_7.enabled: true
        -

        changed: [fb-instance]

        TASK [Enable and configure the system module] **********************************************************************
        changed: [fb-instance]

        TASK [Load Kibana dashboards] **************************************************************************************
        ok: [fb-instance]

        RUNNING HANDLER [restart Filebeat] *********************************************************************************
        changed: [fb-instance]

        PLAY RECAP *********************************************************************************************************
        el-instance                : ok=5    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

        fb-instance                : ok=7    changed=5    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

        k-instance                 : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
        ```

        </details>

        ```log
        PLAY RECAP *********************************************************************************************************
        el-instance                : ok=5    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

        fb-instance                : ok=7    changed=5    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

        k-instance                 : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
        ```

    - Повторно `ansible-playbook -i inventory/prod playbook.yml --diff`

        <details><summary>Полный вывод ansible</summary>

        ```log
        PLAY [Install Elasticsearch] ***************************************************************************************

        TASK [Gathering Facts] *********************************************************************************************
        ok: [el-instance]

        TASK [Download Elasticsearch's rpm] ********************************************************************************
        ok: [el-instance]

        TASK [Install Elasticsearch] ***************************************************************************************
        ok: [el-instance]

        TASK [Configure Elasticsearch] *************************************************************************************
        ok: [el-instance]

        TASK [Configure Elastic JVM] ***************************************************************************************
        ok: [el-instance]

        PLAY [Install Kibana] **********************************************************************************************

        TASK [Gathering Facts] *********************************************************************************************
        ok: [k-instance]

        TASK [Download Kibana's rpm] ***************************************************************************************
        ok: [k-instance]

        TASK [Install Kibana] **********************************************************************************************
        ok: [k-instance]

        TASK [Configure Kibana] ********************************************************************************************
        ok: [k-instance]

        PLAY [Install Filebeat] ********************************************************************************************

        TASK [Gathering Facts] *********************************************************************************************
        ok: [fb-instance]

        TASK [Download Filebeat's rpm] *************************************************************************************
        ok: [fb-instance]

        TASK [Install Filebeat] ********************************************************************************************
        ok: [fb-instance]

        TASK [Configure Filebeat] ******************************************************************************************
        ok: [fb-instance]

        TASK [Enable and configure the system module] **********************************************************************
        ok: [fb-instance]

        TASK [Load Kibana dashboards] **************************************************************************************
        ok: [fb-instance]

        PLAY RECAP *********************************************************************************************************
        el-instance                : ok=5    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

        fb-instance                : ok=6    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

        k-instance                 : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
        ```

        </details>

        ```log
        PLAY RECAP *********************************************************************************************************
        el-instance                : ok=5    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

        fb-instance                : ok=6    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

        k-instance                 : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
        ```

10. Подготовьте README.md файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги.

    [README.md](./playbook/README.md)

11. Готовый playbook выложите в свой репозиторий, в ответ предоставьте ссылку на него.

    [playbook](./playbook/)