
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
