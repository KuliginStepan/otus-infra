terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

resource "random_id" "cluster-id" {
  byte_length = 8
}

resource "yandex_kms_symmetric_key" "k8s-cluster-kms-key" {
  name = "k8s-cluster-kms-key-${random_id.cluster-id.hex}"
  description = "Key for encrypting in k8s cluster ${random_id.cluster-id.hex}"
}

resource "yandex_kubernetes_cluster" "credit-club-k8s-cluster" {
  depends_on = [
    yandex_resourcemanager_folder_iam_member.k8s-manager,
    yandex_resourcemanager_folder_iam_member.k8s-node-manager
  ]
  name = var.master.name
  description = var.master.description
  network_id = var.network_id
  kms_provider {
    key_id = yandex_kms_symmetric_key.k8s-cluster-kms-key.id
  }
  master {
    regional {
      region = "ru-central1"
      dynamic "location" {
        for_each = yandex_vpc_subnet.cluster_subnets
        content {
          zone = location.value.zone
          subnet_id = location.value.id
        }
      }
    }
    version = var.master.version
    public_ip = var.master.public_ip
  }
  service_account_id = yandex_iam_service_account.k8s-manager.id
  node_service_account_id = yandex_iam_service_account.k8s-node-manager.id
  release_channel = var.master.release_channel

  provisioner "local-exec" {
    command = "yc managed-kubernetes cluster get-credentials ${self.id} --external --force --kubeconfig ${pathexpand("~/.kube/terraform-config")}"
  }

  provisioner "local-exec" {
    when = destroy
    command = "rm ${pathexpand("~/.kube/terraform-config")}"
  }
}

resource "yandex_kubernetes_node_group" "credit-club-k8s-main-node-group" {
  count = length(var.node_groups)
  cluster_id = yandex_kubernetes_cluster.credit-club-k8s-cluster.id
  name = var.node_groups[count.index].name
  description = "Main node group for Credit.Club k8s cluster"

  instance_template {
    platform_id = var.node_groups[count.index].platform_id
    resources {
      memory = var.node_groups[count.index].resources["memory"]
      cores = var.node_groups[count.index].resources["cores"]
    }
    boot_disk {
      type = var.node_groups[count.index].boot_disk["type"]
      size = var.node_groups[count.index].boot_disk["size"]
    }
  }
  scale_policy {
    fixed_scale {
      size = var.node_groups[count.index].scale_policy.fixed_scale["size"]
    }
  }

  allocation_policy {
    dynamic "location" {
      for_each = yandex_vpc_subnet.cluster_subnets
      content {
        zone = location.value.zone
        subnet_id = location.value.id
      }
    }
  }
}