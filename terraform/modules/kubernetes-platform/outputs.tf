output "gitlab-token" {
  value = data.kubernetes_secret.gitlab.data.token
}