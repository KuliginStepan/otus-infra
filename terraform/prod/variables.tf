variable "cloud_id" {
  description = "Yandex Cloud ID"
}

variable "folder_id" {
  description = "Yandex.Cloud Folder ID"
}

variable "zone" {
  description = "Default zone"
  default = "ru-central1-a"
}

variable "service_account_key_file" {
  description = "Path to Yandex.Cloud service account file"
}

variable "gitlab_token" {}

variable "cluster_domain" {
  default = "cluster.local"
}