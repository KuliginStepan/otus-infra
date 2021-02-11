provider "gitlab" {
  token = var.gitlab_token
}

resource "gitlab_group" "group" {
  name = "skuligin-otus"
  path = "skuligin-otus"
  visibility_level = "public"
}

resource "gitlab_deploy_token" "image-deploy-token" {
  group = gitlab_group.group.path
  name = "image-deploy-token"
  expires_at = "2100-01-01T00:00:00Z"
  scopes = ["read_registry"]
}

resource "gitlab_group_cluster" "group_cluster" {
  group = gitlab_group.group.id
  kubernetes_api_url = module.kubernetes-cluster.external_v4_endpoint
  kubernetes_token = module.kubernetes-platform.gitlab-token
  name = module.kubernetes-cluster.cluster_name
  //https://github.com/gitlabhq/terraform-provider-gitlab/issues/256
  kubernetes_ca_cert = trimspace(module.kubernetes-cluster.cluster_ca_certificate)
  managed = false
}

resource "gitlab_project" "search-engine-ui" {
  name = "search-engine-ui"
  visibility_level = "public"
  mirror = true
  namespace_id = gitlab_group.group.id
  import_url = "https://github.com/KuliginStepan/search_engine_ui.git"
}

resource "kubernetes_secret" "gitlab-registry-secret" {
  metadata {
    name = "gitlab-registry-credentials"
    namespace = kubernetes_namespace.search_engine.metadata.0.name
  }
  data = {
    ".dockerconfigjson" = data.template_file.docker_config_script.rendered
  }
  type = "kubernetes.io/dockerconfigjson"
}

resource "kubernetes_namespace" "search_engine" {
  metadata {
    name = "search-engine"
  }
}

data "template_file" "docker_config_script" {
  template = file("${path.module}/config.json")
  vars = {
    docker-username           = gitlab_deploy_token.image-deploy-token.username
    docker-password           = gitlab_deploy_token.image-deploy-token.token
    docker-server             = "registry.gitlab.com"
  }
}


locals {
  search_engine_mongodb_user = module.mongodb_cluster.users[index(module.mongodb_cluster.users.*.name, "search_engine")]
}

resource "gitlab_group_variable" "mongo-url" {
  key = "MONGO_URL"
  value = "mongodb://${local.search_engine_mongodb_user.name}:${local.search_engine_mongodb_user.password}@${module.mongodb_cluster.hosts_string}/search_engine"
  group = gitlab_group.group.id
}

resource "gitlab_project_variable" "rmq-host" {
  key = "RMQ_HOST"
  project = gitlab_project.search-engine-crawler.id
  value = "rabbitmq.rabbitmq"
}

resource "gitlab_project" "search-engine-crawler" {
  name = "search-engine-crawler"
  visibility_level = "public"
  mirror = true
  namespace_id = gitlab_group.group.id
  import_url = "https://github.com/KuliginStepan/search_engine_crawler.git"
}