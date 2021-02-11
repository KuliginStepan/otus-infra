resource "yandex_iam_service_account" "k8s-manager" {
  name = "k8s-manager-${random_id.cluster-id.hex}"
  description = "service account to manage k8s cluster ${random_id.cluster-id.hex}"
}

resource "yandex_resourcemanager_folder_iam_member" "k8s-manager" {
  folder_id = var.folder_id

  role = "editor"
  member = "serviceAccount:${yandex_iam_service_account.k8s-manager.id}"
}

resource "yandex_iam_service_account" "k8s-node-manager" {
  name = "k8s-node-manager-${random_id.cluster-id.hex}"
  description = "service account to manage k8s cluster (${random_id.cluster-id.hex}) nodes"
}

resource "yandex_resourcemanager_folder_iam_member" "k8s-node-manager" {
  folder_id = var.folder_id

  role = "editor"
  member = "serviceAccount:${yandex_iam_service_account.k8s-node-manager.id}"
}