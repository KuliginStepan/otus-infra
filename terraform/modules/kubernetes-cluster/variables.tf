variable "nat" {
  type = object({
    ipv4_address = string
    zone_id = string
    v4_cidr_blocks = list(string)
  })

  default = {
    ipv4_address = ""
    zone_id = "ru-central1-a"
    v4_cidr_blocks = ["10.242.0.0/16"]
  }
}

variable "folder_id" {
  description = "Yandex.Cloud Folder ID"
}

variable "network_id" {}

variable "openvpn" {
  type = object({
    mongodb_uri = string
    public_ip_address = string
  })
  default = {
    mongodb_uri = ""
    public_ip_address = ""
  }
}

variable "cluster_subnets" {
  type = list(object({
    zone = string
    v4_cidr_blocks = list(string)
  }))
  default = [
    {
      zone = "ru-central1-a"
      v4_cidr_blocks = ["10.243.0.0/16"]
    },
    {
      zone = "ru-central1-b"
      v4_cidr_blocks = ["10.244.0.0/16"]
    },
    {
      zone = "ru-central1-c"
      v4_cidr_blocks = ["10.245.0.0/16"]
    }
  ]
}

variable "master" {
  type = object({
    name = string
    description = string
    version = string
    public_ip = bool
    release_channel = string
  })

  default = {
    name = "kubernetes-cluster"
    description = "Kubernetes Cluster"
    version = "1.19"
    public_ip = true
    release_channel = "RAPID"
  }
}

variable "node_groups" {
  type = list(object({
    name = string
    description = string
    platform_id = string
    resources = object({
      memory = number
      cores = number
    })
    boot_disk = object({
      type = string
      size = number
    })
    scale_policy = object({
      fixed_scale = object({
        size = number
      })
    })
  }))

  default = [
    {
      name = "main-node-group"
      description = "Main node group for k8s cluster"
      platform_id = "standard-v2"
      resources = {
        memory = 8
        cores = 4
      }
      boot_disk = {
        type = "network-hdd"
        size = 64
      }
      scale_policy = {
        fixed_scale = {
          size = 3
        }
      }
    }
  ]
}