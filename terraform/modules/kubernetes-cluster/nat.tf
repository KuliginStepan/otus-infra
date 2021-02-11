
data "yandex_compute_image" "nat-instance" {
  family = "nat-instance-ubuntu"
}

resource "yandex_compute_instance" "nat-instance" {
  name = "nat-instance-${random_id.cluster-id.hex}"
  platform_id = "standard-v1"
  zone = var.nat.zone_id

  allow_stopping_for_update = true

  resources {
    cores = 2
    memory = 1
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.nat-instance.id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.k8s-cluster-nat-subnet.id
    nat = true
    nat_ip_address = var.nat.ipv4_address
  }
}
