resource "yandex_compute_instance" "node01" {
  name                      = "reversproxy"
  zone                      = "ru-central1-a"
  hostname                  = "diplomvitkos.site"
  allow_stopping_for_update = true

  resources {
    cores  = 4
    memory = 4
  }


  boot_disk {
    initialize_params {
      image_id    = "fd8fte6bebi857ortlja" #"fd83slullt763d3lo57m"
      type        = "network-ssd"
      size        = "10"
    }
  }

  network_interface {
    subnet_id  = "${yandex_vpc_subnet.public-zone.id}"
    nat        = true
    nat_ip_address = var.reserved_ip
    ip_address = "192.168.100.11"
  }

  metadata = {
    user-data = "${file("meta.txt")}"
  }
}

#  metadata = {
#    ssh-keys = "konstantin:${file("~/.ssh/id_rsa.pub")}"
#  }
#}
