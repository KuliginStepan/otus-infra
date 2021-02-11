output "k8s_public_ip" {
  value = module.kubernetes-cluster.external_v4_endpoint
}