resource "yandex_compute_instance" "node06" {
  name                      = "runner"
  zone                      = "ru-central1-b"
  hostname                  = "runner.diplomvitkos.site"
  allow_stopping_for_update = true

  resources {
    cores  = 4
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id    = "fd8fte6bebi857ortlja"
      name        = "root-node06"
      type        = "network-ssd"
      size        = "10"
    }
  }

  network_interface {
    subnet_id  = "${yandex_vpc_subnet.subnet-for-instanses.id}"
    nat        = false
    ip_address = "192.168.110.16"
  }

  metadata = {
    user-data = "${file("meta.txt")}"
  }
}

#  metadata = {
#    ssh-keys = "konstantin:${file("~/.ssh/id_rsa.pub")}"
#  }
#}



