terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "random" {}

resource "random_password" "user_password" {
  count = length(var.databases)
  length = 20
  special = false
}

resource "random_password" "admin_password" {
  length = 20
  special = false
}

resource "yandex_vpc_subnet" "cluster_subnet" {
  count = min(var.resources.hosts_count, length(var.subnets))
  name = "${var.name}-subnet-${count.index}"
  network_id = var.network_id
  zone = var.subnets[count.index].zone
  v4_cidr_blocks = var.subnets[count.index].v4_cidr_blocks
}

resource "yandex_mdb_mongodb_cluster" "mongodb_cluster" {
  environment = var.environment
  name = var.name
  network_id = var.network_id
  cluster_config {
    version = var.cluster_version
  }
  dynamic "database" {
    for_each = var.databases
    content {
      name = database.value
    }
  }
  dynamic "host" {
    for_each = range(var.resources.hosts_count)
    content {
      subnet_id = element(yandex_vpc_subnet.cluster_subnet, host.value).id
      zone_id = element(yandex_vpc_subnet.cluster_subnet, host.value).zone
    }
  }

  resources {
    disk_size = var.resources.disk_size
    disk_type_id = var.resources.disk_type_id
    resource_preset_id = var.resources.resource_preset_id
  }

  dynamic "user" {
    for_each = var.databases
    content {
      name = user.value
      password = random_password.user_password[user.key].result
      permission {
        database_name = user.value
        roles = ["readWrite"]
      }
    }
  }

  user {
    name = var.cluster_admin.username
    password = random_password.admin_password.result
    dynamic "permission" {
      for_each = var.databases
      content {
        database_name = permission.value
        roles = ["readWrite"]
      }
    }
  }
}
