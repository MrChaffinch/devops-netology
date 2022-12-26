resource "yandex_vpc_network" "public-net" {
  name = "yc-network"
}

resource "yandex_vpc_subnet" "lab-subnet-a" {
  name           = "public"
  v4_cidr_blocks = ["192.168.10.0/24"]
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.public-net.id}"
}

resource "yandex_vpc_subnet" "lab-subnet-b" {
  name           = "private"
  v4_cidr_blocks = ["192.168.20.0/24"]
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.public-net.id}"
  route_table_id = "${yandex_vpc_route_table.internet-for-private.id}"
}

resource "yandex_vpc_route_table" "internet-for-private" {
  network_id = "${yandex_vpc_network.public-net.id}"

  static_route  { 
    destination_prefix = "0.0.0.0/0"
    next_hop_address = "192.168.10.254"
  }
}
