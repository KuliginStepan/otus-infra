variable "network_id" {
  type = string
}

variable "subnets" {
  type = list(object({
    zone = string
    v4_cidr_blocks = list(string)
  }))

  default = [
    {
      zone = "ru-central1-a"
      v4_cidr_blocks = ["10.1.0.0/16"]
    },
    {
      zone = "ru-central1-b"
      v4_cidr_blocks = ["10.2.0.0/16"]
    },
    {
      zone = "ru-central1-c"
      v4_cidr_blocks = ["10.3.0.0/16"]
    }
  ]
}

variable "name" {
  default = "mongodb-cluster"
}

variable "cluster_version" {
  default = "4.2"
}

variable "resources" {
  type = object({
    resource_preset_id = string
    disk_size = number
    disk_type_id = string
    hosts_count = number
  })
  default = {
    resource_preset_id = "b1.nano"
    disk_size = 16
    disk_type_id = "network-hdd"
    hosts_count = 1
  }
}

variable "cluster_admin" {
  type = object({
    username = string
  })
  default = {
    username = "cluster-admin"
  }
}

variable "databases" {
  type = list(string)
  default = []
}

variable "environment" {
  type = string
  default = "PRESTABLE"

  validation {
    condition = contains(["PRESTABLE", "PRODUCTION"], var.environment)
    error_message = "Valid values for environments are one of PRESTABLE or PRODUCTION."
  }
}