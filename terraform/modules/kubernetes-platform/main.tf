terraform {
  required_providers {
    helmfile = {
      source = "mumoshu/helmfile"
    }
  }
}

resource "helmfile_release_set" "platform" {
  content = file("${path.module}/../../../helmfile.d/helmfile.yaml")
  working_directory = "${path.module}/../../../helmfile.d"
  kubeconfig = pathexpand("~/.kube/terraform-config")

  values = [
    yamlencode({
      ingress = {
        loadBalancerIP = var.ingress_ip_address
      }
      vpn = {
        mongodbUri = var.openvpn.mongodb_uri
        publicIp = var.openvpn.public_ip_address
      }
      gitlab = {
        runnerRegistrationToken = var.runner_registration_token
      }
    })
  ]
}

resource "kubernetes_service_account" "gitlab" {
  metadata {
    name = "gitlab"
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role_binding" "gitlab" {
  metadata {
    name = "gitlab-admin"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "ClusterRole"
    name = "cluster-admin"
  }
  subject {
    kind = "ServiceAccount"
    name = "gitlab"
    namespace = "kube-system"
  }
}

data "kubernetes_secret" "gitlab" {
  metadata {
    name = kubernetes_service_account.gitlab.default_secret_name
    namespace = "kube-system"
  }
}

resource "local_file" "coredns-user-config" {
  filename = "${path.root}/coredns-user.yml"
  content = <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns-user
  namespace: kube-system
data:
  Corefile: |
    cluster.${var.environment}:53 {
      errors
      rewrite stop {
        name regex (.*)\.cluster\.${var.environment} {1}.cluster.local
        answer name (.*)\.cluster\.local {1}.cluster.${var.environment}
      }
      forward . 127.0.0.1:53
      reload
    }
EOF

  provisioner "local-exec" {
    command = "kubectl apply -f ${self.filename} --kubeconfig ${pathexpand("~/.kube/terraform-config")}"
  }
}