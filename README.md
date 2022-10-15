# DEVOPS-DIPLOM-YandexCloud (VITKIN_K_N)

## Цели:

>1. Зарегистрировать доменное имя (любое на ваш выбор в любой доменной зоне).
>2. Подготовить инфраструктуру с помощью Terraform на базе облачного провайдера YandexCloud.
>3. Настроить внешний Reverse Proxy на основе Nginx и LetsEncrypt.
>4. Настроить кластер MySQL.
>5. Установить WordPress.
>6. Развернуть Gitlab CE и Gitlab Runner.
>7. Настроить CI/CD для автоматического развёртывания приложения.
>8. Настроить мониторинг инфраструктуры с помощью стека: Prometheus, Alert Manager и Grafana.

### *1. Зарегистрируем доменное имя.*



### *2. Создание инфраструктуры.*

#### *Создайте сервисный аккаунт, который будет в дальнейшем использоваться Terraform для работы с инфраструктурой с необходимыми и достаточными правами. Не стоит использовать права суперпользователя*
```bash
konstantin@konstantin-forever:~$ yc --version
Yandex Cloud CLI 0.94.0 linux/amd64
```
```bash
konstantin@konstantin-forever:~$ yc iam service-account create --name diplome-account
id: ajeb8i90e6jg5rv4ta3i
folder_id: b1g3r78e9ad9be8bcmdr
created_at: "2022-08-24T17:30:29.716628648Z"
name: diplome-account
konstantin@konstantin-forever:~$ yc resource-manager folder add-access-binding netology \
--role editor \
--subject serviceAccount:ajeb8i90e6jg5rv4ta3i
done (2s)
```
- *Создадим ключ авторизации для сервисного аккаунта diplome-account*
```
konstantin@konstantin-forever:~$ yc iam access-key create --folder-name netology --service-account-name diplome-account
access_key:
  id: ajef8tdl56p56nc9tqq8
  service_account_id: ajeb8i90e6jg5rv4ta3i
  created_at: "2022-08-24T17:36:01.179805285Z"
  key_id: YCAJEqccg56QvRbco5h11wmUu
secret: YCNCKDGBwk8nqCsmevSVrGuh_C7P9kZLIqUNwExD
```
- *Создадим ключ доступа для сервисного аккаунта diplome-account*
```
konstantin@konstantin-forever:~$ yc iam key create --folder-name netology --service-account-name diplome-account --output key.json
id: ajelvk0504kuek9triq1
service_account_id: ajeb8i90e6jg5rv4ta3i
created_at: "2022-08-24T17:38:16.718829975Z"
key_algorithm: RSA_2048

```
- *Подготовим backend для Terraform*
- *Создадим бакет `diplom-s3-backet (предварительно установим awscli)*
```
konstantin@konstantin-forever:~/DEVOPS_COURSE/DIPLOM$ alias ycs3='aws s3 --endpoint-url=https://storage.yandexcloud.net'
konstantin@konstantin-forever:~/DEVOPS_COURSE/DIPLOM$ aws configure
AWS Access Key ID [None]: YCAJEqccg56QvRbco5h11wmUu
AWS Secret Access Key [None]: YCNCKDGBwk8nqCsmevSVrGuh_C7P9kZLIqUNwExD
Default region name [None]: ru-central1
Default output format [None]: table
konstantin@konstantin-forever:~/DEVOPS_COURSE/DIPLOM$ ycs3 mb s3://diplom-s3-backet
make_bucket: diplom-s3-backet
```
- *Создадим VPC с подсетями в разных зонах доступности.*
[network.tf](terraform/stage/network.tf)
```
resource "yandex_vpc_network" "vpc-for-diplom" {
  name = "diplomnet"
}

resource "yandex_vpc_route_table" "route-table" {
  network_id = yandex_vpc_network.vpc-for-diplom.id
  name                    = "natroute"
  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = "192.168.100.11"
  }
}

resource "yandex_vpc_subnet" "public-zone" {
  name = "subneta"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.vpc-for-diplom.id
  v4_cidr_blocks = ["192.168.100.0/24"]
  route_table_id = yandex_vpc_route_table.route-table.id
}

resource "yandex_vpc_subnet" "subnet-for-instanses" {
  name = "subnetb"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.vpc-for-diplom.id
  v4_cidr_blocks = ["192.168.110.0/24"]
  route_table_id = yandex_vpc_route_table.route-table.id
}
```

- *Подготовим backend для Terraform*
```
konstantin@konstantin-forever:~/DEVOPS_COURSE/DIPLOM/terraform/stage$ terraform init

Initializing the backend...

Initializing provider plugins...
- Finding latest version of hashicorp/null...
- Finding latest version of hashicorp/local...
- Finding latest version of yandex-cloud/yandex...
- Installing hashicorp/null v3.1.1...
- Installed hashicorp/null v3.1.1 (signed by HashiCorp)
- Installing hashicorp/local v2.2.3...
- Installed hashicorp/local v2.2.3 (signed by HashiCorp)
- Installing yandex-cloud/yandex v0.78.0...
- Installed yandex-cloud/yandex v0.78.0 (self-signed, key ID E40F590B50BB8E40)

Partner and community providers are signed by their developers.
If you'd like to know more about provider signing, you can read about it here:
https://www.terraform.io/docs/cli/plugins/signing.html

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
onstantin@konstantin-forever:~/DEVOPS_COURSE/DIPLOM/terraform/stage$ terraform plan

Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # local_file.inventory will be created
  + resource "local_file" "inventory" {
      + content              = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "../ansible/inventory"
      + id                   = (known after apply)
    }

  # null_resource.cluster will be created
  + resource "null_resource" "cluster" {
      + id = (known after apply)
....

....

Plan: 16 to add, 0 to change, 0 to destroy.
```
![](https://github.com/VitkinKN/diplom_yandex_cloud/blob/master/images/1.jpg )

- *Создадим workspace `stage`*
```
konstantin@konstantin-forever:~/DEVOPS_COURSE/DIPLOM/terraform/stage$ terraform workspace new stage
Created and switched to workspace "stage"!

You're now on a new, empty workspace. Workspaces isolate their state,
so if you run "terraform plan" Terraform will not see any existing state
for this configuration.
konstantin@konstantin-forever:~/DEVOPS_COURSE/DIPLOM/terraform/stage$ terraform workspace list
  default
* stage
```
- *Убедимся, что теперь можно выполнить команды terraform destroy и terraform apply без дополнительных ручных действий.*

- *Поднимаются 7 VM, все на основе образа ubuntu - имеет внешний статический IP адрес, арендованный у YandexCloud -51.250.6.241*
- *Домен был делегирован под управление ns1.yandexcloud.net и ns2.yandexcloud.net*

![](https://github.com/VitkinKN/diplom_yandex_cloud/blob/master/images/3.jpg )

- *Происходит автоматическая регистрация DNS записей в YandexCloud.*
![](https://github.com/VitkinKN/diplom_yandex_cloud/blob/master/images/2.jpg )

```
terraform apply

Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # local_file.inventory will be created
,,,
,,,
konstantin@konstantin-forever:~/DEVOPS_COURSE/DIPLOM/terraform/stage$ terraform destroy
yandex_vpc_network.vpc-for-diplom: Refreshing state... [id=enprgek46caf4imid63c]
yandex_vpc_subnet.public-zone: Refreshing state... [id=e9b2f21etmrbsi7u665d]
yandex_vpc_route_table.nat-for-diplom: Refreshing state... [id=enpu6ugubo9rh0m5l33h]
yandex_vpc_subnet.subnet-for-instanses: Refreshing state... [id=e2loaavo5k1ps2k7oosk]
...
yandex_vpc_subnet.subnet-for-instanses: Destroying... [id=e2loaavo5k1ps2k7oosk]
yandex_vpc_subnet.public-zone: Destroying... [id=e9b2f21etmrbsi7u665d]
yandex_vpc_subnet.subnet-for-instanses: Destruction complete after 7s
yandex_vpc_route_table.nat-for-diplom: Destroying... [id=enpu6ugubo9rh0m5l33h]
yandex_vpc_route_table.nat-for-diplom: Destruction complete after 0s
yandex_vpc_subnet.public-zone: Destruction complete after 8s
yandex_vpc_network.vpc-for-diplom: Destroying... [id=enprgek46caf4imid63c]
yandex_vpc_network.vpc-for-diplom: Destruction complete after 0s

Destroy complete! Resources: 4 destroyed.

```
___

### *Установка Nginx и LetsEncrypt*

- *Разработана [роль](./ansible/roles/nginx) для установки nginx и сертификата lets Encr (однако исчерпав лимит на рабочий cert перешол на тестовый)*
<details>
<summary>Работа TASK.</summary>
PLAY [Install Nginx letsencrypt] ***********************************************

TASK [Gathering Facts] *********************************************************
ok: [diplomvitkos.site]

TASK [nginx : Updating remote system] ******************************************
ok: [diplomvitkos.site]

TASK [nginx : Installing nginx and letsencrypt] ********************************
ok: [diplomvitkos.site]

TASK [nginx : Setuping nginx - step 1. remove default site config] *************
ok: [diplomvitkos.site]

TASK [nginx : Setuping nginx - step 2. install nginx basic http site] **********
changed: [diplomvitkos.site]

TASK [nginx : Reloading nginx] *************************************************
changed: [diplomvitkos.site]

TASK [nginx : Preparing letsencrypt - step 1. create letsencrypt directory] ****
ok: [diplomvitkos.site]

TASK [nginx : Prepering letsencrypt - step 2. create certificate] **************
changed: [diplomvitkos.site]

TASK [nginx : Finishing nginx setup - install nginx config] ********************
changed: [diplomvitkos.site]

TASK [nginx : Finishing nginx setup - enable https] ****************************
changed: [diplomvitkos.site]

TASK [nginx : Finishing nginx setup - add basic html page] *********************
changed: [diplomvitkos.site]

TASK [nginx : Reloading nginx] *************************************************
changed: [diplomvitkos.site]

TASK [nodeexporter : Create node exporter group] *******************************
changed: [diplomvitkos.site]

TASK [nodeexporter : Create node exporter user] ********************************
changed: [diplomvitkos.site]

TASK [nodeexporter : Create directory for config node exporter] ****************
changed: [diplomvitkos.site]

TASK [nodeexporter : Download and unzip node exporter] *************************
changed: [diplomvitkos.site]

TASK [nodeexporter : Move src to final destination] ****************************
changed: [diplomvitkos.site]

TASK [nodeexporter : Delete tmp files] *****************************************
changed: [diplomvitkos.site]

TASK [nodeexporter : Install node exporter as service] *************************
changed: [diplomvitkos.site]

RUNNING HANDLER [nodeexporter : Restart node exporter] *************************
changed: [diplomvitkos.site]

TASK [nodeexporter : Service always startup - systemd] *************************
ok: [diplomvitkos.site]
</details>

- *Открываем в браузере любой из URL нашего кластера и видем ответ сервера (502 Bad Gateway)*
![](https://github.com/VitkinKN/diplom_yandex_cloud/blob/master/images//5.jpg )
![](https://github.com/VitkinKN/diplom_yandex_cloud/blob/master/images/6.jpg )
![](https://github.com/VitkinKN/diplom_yandex_cloud/blob/master/images/7.jpg )
![](https://github.com/VitkinKN/diplom_yandex_cloud/blob/master/images/9.jpg )
___
### *Установка MySQL*

- *Разработана Ansible [роль](./ansible/roles/mysql) для установки Mysql*
- *Установка проходит на 2 ноды в режиме master slave*
___

### *Установка wordpress*

- *Разработана [роль](./ansible/roles/wordpress) для установки wordpress*
![](https://github.com/VitkinKN/diplom_yandex_cloud/blob/master/images/11.jpg )
![](https://github.com/VitkinKN/diplom_yandex_cloud/blob/master/images/10.jpg )

___
### *Установка Gitlab CE и Gitlab Runner*
-*Настроим CI|CD систему для автоматического развертывания приложения при изменения кода*
- *Разработана [роль](./ansible/roles/runner) для установки runnerа (предварительно нв репозитории gitlab.diplomvitkos.site и получили токен)*
![](https://github.com/VitkinKN/diplom_yandex_cloud/blob/master/images/17(gitlabtoken-registr).jpg )
- *Имена серверов gitlab.diplomvitkos.site и runner.diplomvitkos.site*
- *runner подключается автоматически на основе заранее прописанного токена*
![](https://github.com/VitkinKN/diplom_yandex_cloud/blob/master/images/17(gitlabtoken-onlain).jpg )
- *Создаем репозиторий wordpress*
- *Добавляем файл gitlab-ci.yml*
- *На хосте app генерим SSH ключи, открытый ключ перенаправляем в authorized_keys, а закрытый ложим в gitlab для подключения к арр*
```
---
before_script:
  - 'which ssh-agent || ( apt-get update -y && apt-get install openssh-client -y )'
  - eval $(ssh-agent -s)
  - echo "$ID_RSA" | tr -d '\r' | s
  - mkdir -p ~/.ssh
  - chmod 700 ~/.ssh

stages:
  - deploy

deploy-job:
  stage: deploy
  script:
    - echo "Deploy"
    - ssh -o StrictHostKeyChecking=no konstantin@app.diplomvitkos.site sudo chown konstantin /var/www/wordpress/ -R
    - rsync -rvz -e "ssh -o StrictHostKeyChecking=no" ./* konstantin@app.diplomvitkos.site:/var/www/wordpress/
    - ssh -o StrictHostKeyChecking=no konstantin@app.exraydi.ru rm -rf /var/www/wordpress/.git
    - ssh -o StrictHostKeyChecking=no konstantin@app.exraydi.ru sudo chown www-data /var/www/wordpress/ -R
```
- *При commite запускается deploy*
![](https://github.com/VitkinKN/diplom_yandex_cloud/blob/master/images/18(gitlab_ci).jpg )
- *Результат работы deploy*
![](https://github.com/VitkinKN/diplom_yandex_cloud/blob/master/images/.jpg )

<details>
<summary>Работа TASK при установке runner</summary>
PLAY [Install runner] **********************************************************

TASK [Gathering Facts] *********************************************************
ok: [runner.diplomvitkos.site]

TASK [runner : Download GitLab repository installation script.] ****************
ok: [runner.diplomvitkos.site]

TASK [runner : Install GitLab repository.] *************************************
ok: [runner.diplomvitkos.site]

TASK [runner : Install GitLab runner] ******************************************
ok: [runner.diplomvitkos.site]

TASK [runner : register runner] ************************************************
changed: [runner.diplomvitkos.site]

TASK [runner : Add gitlab-runner user to sudoers] ******************************
changed: [runner.diplomvitkos.site]

TASK [runner : Allow gitlab-runner user to have passwordless sudo] *************
changed: [runner.diplomvitkos.site]

TASK [runner : start and enable gitlab-runner] *********************************
ok: [runner.diplomvitkos.site]

PLAY RECAP *********************************************************************
runner.diplomvitkos.site   : ok=8    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
</details>
___

### *Установка Prometheus, Alert Manager, Node Exporter и Grafana*
- *Разработана Ansible [роль](./ansible/roles/monitoring)для становки Prometheus, Alert Manager и [ роль Grafana](./ansible/roles/grafana) для Grafana.*
- *Имя сервера monitoring.diplomvitkos.site*
- *В домменной зоне настроены [А-записи](./terraform/dns.tf) на внешний адрес reverse proxy:*
- *https://grafana.diplomvitkos.site (Grafana)*
- *https://prometheus.diplomvitkos.site (Prometheus)*
- *https://alertmanager.diplomvitkos.site (Alert Manager)*
- *На всех серверах установлен [Node Exporter](./ansible/roles/nodeexporter) и его метрики доступны Prometheus.*
![](https://github.com/VitkinKN/diplom_yandex_cloud/blob/master/images/13(prometeus).jpg )
- *У Alert Manager есть необходимый набор правил для создания алертов*
![](https://github.com/VitkinKN/diplom_yandex_cloud/blob/master/images/15(alertmen).jpg )
- *В Grafana есть дашборд отображающий метрики из Node Exporter по всем серверам.*
![](https://github.com/VitkinKN/diplom_yandex_cloud/blob/master/images/14(grafana).jpg )
![](https://github.com/VitkinKN/diplom_yandex_cloud/blob/master/images/16(grafana).jpg )
___







