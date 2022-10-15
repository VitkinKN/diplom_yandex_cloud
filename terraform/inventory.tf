resource "local_file" "inventory" {
  content = <<-DOC


    [reversproxy]
    diplomvitkos.site email=konstantin@diplomvitkos.site domain=diplomvitkos.site
    [reversproxy:vars]
    ansible_host=${yandex_compute_instance.node01.network_interface.0.nat_ip_address}
    ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
    
    [db01]
    db01.diplomvitkos.site mysql_server_id=1 mysql_replication_role=master
    [db01:vars]
    ansible_host=${yandex_compute_instance.node02.network_interface.0.ip_address}
    ansible_ssh_common_args='-o ControlMaster=auto -o ControlPersist=10m -o ProxyCommand="ssh -W %h:%p -q konstantin@diplomvitkos.site"'

    [db02]
    db02.diplomvitkos.site mysql_server_id=2 mysql_replication_role=slave
    [db02:vars]
    ansible_host=${yandex_compute_instance.node03.network_interface.0.ip_address}
    ansible_ssh_common_args='-o ControlMaster=auto -o ControlPersist=10m -o ProxyCommand="ssh -W %h:%p -q konstantin@diplomvitkos.site"'

    [app]
    app.diplomvitkos.site
    [app:vars]
    ansible_host=${yandex_compute_instance.node04.network_interface.0.ip_address}
    ansible_ssh_common_args='-o ControlMaster=auto -o ControlPersist=10m -o ProxyCommand="ssh -W %h:%p -q konstantin@diplomvitkos.site"'

    [gitlab]
    gitlab.diplomvitkos.site
    [gitlab:vars]
    ansible_host=${yandex_compute_instance.node05.network_interface.0.ip_address}
    ansible_ssh_common_args='-o ControlMaster=auto -o ControlPersist=10m -o ProxyCommand="ssh -W %h:%p -q konstantin@diplomvitkos.site"'

    [runner]
    runner.diplomvitkos.site domain_name=diplomvitkos.site
    [runner:vars]
    ansible_host=${yandex_compute_instance.node06.network_interface.0.ip_address}
    ansible_ssh_common_args='-o ControlMaster=auto -o ControlPersist=10m -o ProxyCommand="ssh -W %h:%p -q konstantin@diplomvitkos.site"'

    [monitoring]
    monitoring.diplomvitkos.site domain_name=diplomvitkos.site
    [monitoring:vars]
    ansible_host=${yandex_compute_instance.node07.network_interface.0.ip_address}
    ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
    ansible_ssh_common_args='-o ControlMaster=auto -o ControlPersist=10m -o ProxyCommand="ssh -W %h:%p -q konstantin@diplomvitkos.site"'

    [allhosts:children]
    node01
    node02
    node03
    node04
    node05
    node06
    node07

    ip_node01 = ${yandex_compute_instance.node01.network_interface.0.ip_address}
    ip_node02 = ${yandex_compute_instance.node02.network_interface.0.ip_address}
    ip_node03 = ${yandex_compute_instance.node03.network_interface.0.ip_address}
    ip_node04 = ${yandex_compute_instance.node04.network_interface.0.ip_address}
    ip_node05 = ${yandex_compute_instance.node05.network_interface.0.ip_address}
    ip_node06 = ${yandex_compute_instance.node06.network_interface.0.ip_address}
    ip_node07 = ${yandex_compute_instance.node07.network_interface.0.ip_address}

    DOC
  filename = "../ansible/inventory"

  depends_on = [
    yandex_compute_instance.node01,
    yandex_compute_instance.node02,
    yandex_compute_instance.node03,
    yandex_compute_instance.node04,
    yandex_compute_instance.node05,
    yandex_compute_instance.node06,
    yandex_compute_instance.node07,

  ]
}
