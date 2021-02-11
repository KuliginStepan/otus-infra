output "external_v4_endpoint" {
  value = yandex_kubernetes_cluster.credit-club-k8s-cluster.master.0.external_v4_endpoint
}

output "cluster_ca_certificate" {
  value = yandex_kubernetes_cluster.credit-club-k8s-cluster.master.0.cluster_ca_certificate
}

output "cluster_name" {
  value = yandex_kubernetes_cluster.credit-club-k8s-cluster.name
}

output "node_group_names" {
  value = yandex_kubernetes_node_group.credit-club-k8s-main-node-group.*.name
}

output "kubeconfig_path" {
  value = "~/.kube/terraform-config"
}