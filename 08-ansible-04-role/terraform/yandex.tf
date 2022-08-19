provider "yandex" {
  service_account_key_file = "key.json"
  cloud_id                 = "b1g19qmh5o80gm94ufu8"
  folder_id                = "b1g01oeuesd31te4bm64"
  zone                     = "ru-central1-a"
}

################################################################
# Ищем образ операционки 
data "yandex_compute_image" "ubuntu" {
  family = "centos-7"
}

################################################################
# Сеть и подсеть, они обязтельны
resource "yandex_vpc_network" "net" {
  name = "net"
}

resource "yandex_vpc_subnet" "subnet" {
  name           = "subnet"
  network_id     = resource.yandex_vpc_network.net.id
  v4_cidr_blocks = ["10.2.0.0/16"]
  zone           = "ru-central1-a"
}

################################################################
# Инстансы
resource "yandex_compute_instance" "vm" {
  for_each = {
    el_instance = "netology-83-elk"
    k_instance = "netology-83-k"
    fb_instance = "netology-83-fb"
  }

  name        = each.value
  hostname    = "${each.value}.local"

  platform_id = "standard-v1"

  resources {
    cores         = 2
    memory        = 4
    core_fraction = 100
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      type     = "network-hdd"
      size     = "20"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet.id
    nat       = true
    ipv6      = false
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}
