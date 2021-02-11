terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
    gitlab = {
      source = "gitlabhq/gitlab"
    }
    helmfile = {
      source = "mumoshu/helmfile"
    }
  }
}

data "yandex_client_config" "client" {}

provider "helmfile" {}

provider "kubernetes" {

  host                   = module.kubernetes-cluster.external_v4_endpoint
  cluster_ca_certificate = module.kubernetes-cluster.cluster_ca_certificate
  token                  = data.yandex_client_config.client.iam_token
}

provider "yandex" {
  service_account_key_file = var.service_account_key_file
  cloud_id = var.cloud_id
  folder_id = var.folder_id
  zone = var.zone
}

resource "yandex_vpc_network" "production-network" {
  name = "k8s-cluster-network"
  description = "Network for k8s cluster"
}

resource "yandex_vpc_address" "openvpn" {
  name = "openvpn"
  description = "Public static IP for openvpn server"
  external_ipv4_address {
    zone_id = "ru-central1-a"
  }
}

resource "yandex_vpc_address" "ingress" {
  name = "ingress"
  description = "Public static IP for ingress"
  external_ipv4_address {
    zone_id = "ru-central1-b"
  }
}

module "kubernetes-cluster" {
  source = "../modules/kubernetes-cluster"
  folder_id = var.folder_id
  network_id = yandex_vpc_network.production-network.id
}

module "mongodb_cluster" {
  source = "../modules/mongodb"
  network_id = yandex_vpc_network.production-network.id
  databases = ["pritunl", "search_engine"]
}


locals {
  vpn_mongodb_user = module.mongodb_cluster.users[index(module.mongodb_cluster.users.*.name, "pritunl")]
}

module "kubernetes-platform" {
  source = "../modules/kubernetes-platform"
  ingress_ip_address = yandex_vpc_address.ingress.external_ipv4_address.0.address
  environment = "prod"
  runner_registration_token = gitlab_group.group.runners_token
  openvpn = {
    mongodb_uri = "mongodb://${local.vpn_mongodb_user.name}:${local.vpn_mongodb_user.password}@${module.mongodb_cluster.hosts_string}/pritunl"
    public_ip_address = yandex_vpc_address.openvpn.external_ipv4_address.0.address
  }
  depends_on = [module.kubernetes-cluster]
}