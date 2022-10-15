resource "yandex_compute_instance" "node02" {
  name                      = "db01"
  zone                      = "ru-central1-b"
  hostname                  = "db01.diplomvitkos.site"
  allow_stopping_for_update = true

  resources {
    cores  = 4
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id    = "fd8fte6bebi857ortlja"
      type        = "network-ssd"
      size        = "10"
    }
  }

  network_interface {
    subnet_id  = "${yandex_vpc_subnet.subnet-for-instanses.id}"
    nat        = false
    ip_address = "192.168.110.12"
  }

  metadata = {
    user-data = "${file("meta.txt")}"
  }
}

#  metadata = {
#    ssh-keys = "konstantin:${file("~/.ssh/id_rsa.pub")}"
#  }
#}


resource "yandex_dns_recordset" "rsdb01" {
      zone_id = yandex_dns_zone.domains.id
      name    = "db01.diplomvitkos.site."
      type    = "A"
      ttl     = 200
      data    = ["${yandex_compute_instance.node02.network_interface.0.ip_address}"]
    }
