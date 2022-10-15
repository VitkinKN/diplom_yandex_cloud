resource "yandex_compute_instance" "node07" {
  name                      = "monitoring"
  zone                      = "ru-central1-b"
  hostname                  = "monitoring.diplomvitkos.site"
  allow_stopping_for_update = true

  resources {
    cores  = 4
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id    = "fd8fte6bebi857ortlja"
      name        = "root-node07"
      type        = "network-ssd"
      size        = "15"
    }
  }

  network_interface {
    subnet_id  = "${yandex_vpc_subnet.subnet-for-instanses.id}"
    nat        = false
    ip_address = "192.168.110.17"
  }

  metadata = {
    user-data = "${file("meta.txt")}"
  }
}

#  metadata = {
#    ssh-keys = "konstantin:${file("~/.ssh/id_rsa.pub")}"
#  }
#}

resource "yandex_dns_recordset" "rsmonitoring" {
      zone_id = yandex_dns_zone.domains.id
      name    = "monitoring.diplomvitkos.site."
      type    = "A"
      ttl     = 200
      data    = ["${yandex_compute_instance.node07.network_interface.0.ip_address}"]
    }
