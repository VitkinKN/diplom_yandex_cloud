resource "yandex_compute_instance" "node05" {
  name                      = "gitlab"
  zone                      = "ru-central1-b"
  hostname                  = "gitlab.diplomvitkos.site"
  allow_stopping_for_update = true

  resources {
    cores  = 6
    memory = 6
  }

  boot_disk {
    initialize_params {
      image_id    = "fd8fte6bebi857ortlja"
      type        = "network-ssd"
      size        = "30"
    }
  }

  network_interface {
    subnet_id  = "${yandex_vpc_subnet.subnet-for-instanses.id}"
    nat        = false
    ip_address = "192.168.110.15"
  }

  metadata = {
    user-data = "${file("meta.txt")}"
  }
}

#  metadata = {
#    ssh-keys = "konstantin:${file("~/.ssh/id_rsa.pub")}"
#  }
#}



