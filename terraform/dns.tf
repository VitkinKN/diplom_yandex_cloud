
resource "yandex_dns_zone" "domains" {
  name        = "dns-zone"
  description = "dns zone"

  labels = {
    label1 = "zona-dns"
  }

  zone    = "diplomvitkos.site."
  public  = true

  depends_on = [
    yandex_vpc_subnet.public-zone, yandex_vpc_subnet.subnet-for-instanses
  ]
}

resource "yandex_dns_recordset" "revproxy" {
  zone_id = yandex_dns_zone.domains.id
  name    = "@.diplomvitkos.site."
  type    = "A"
  ttl     = 200
  data    = [yandex_compute_instance.node01.network_interface.0.nat_ip_address]
}

resource "yandex_dns_recordset" "www" {
  zone_id = yandex_dns_zone.domains.id
  name    = "www.diplomvitkos.site."
  type    = "A"
  ttl     = 200
  data    = [yandex_compute_instance.node01.network_interface.0.nat_ip_address]
}

resource "yandex_dns_recordset" "gitlab" {
  zone_id = yandex_dns_zone.domains.id
  name    = "gitlab.diplomvitkos.site."
  type    = "A"
  ttl     = 200
  data    = [yandex_compute_instance.node01.network_interface.0.nat_ip_address]
}

resource "yandex_dns_recordset" "grafana" {
  zone_id = yandex_dns_zone.domains.id
  name    = "grafana"
  type    = "A"
  ttl     = 200
  data    = [yandex_compute_instance.node01.network_interface.0.nat_ip_address]
}

resource "yandex_dns_recordset" "prometheus" {
  zone_id = yandex_dns_zone.domains.id
  name    = "prometheus.diplomvitkos.site."
  type    = "A"
  ttl     = 200
  data    = [yandex_compute_instance.node01.network_interface.0.nat_ip_address]
}

resource "yandex_dns_recordset" "alertmanager" {
  zone_id = yandex_dns_zone.domains.id
  name    = "alertmanager.diplomvitkos.site."
  type    = "A"
  ttl     = 200
  data    = [yandex_compute_instance.node01.network_interface.0.nat_ip_address]
}
