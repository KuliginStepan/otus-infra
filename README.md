# Что включает в себя репозиторий?

- terraform модуль для создания Kubernetes кластера в Yandex.Cloud
- terraform модуль для создания MongoDB кластера в Yandex.Cloud
- terraform модуль для создания дополнительной инфраструктуры в kubernetes кластере:
  - Cert-manager
  - Kubernetes-dashboard
  - Gitlab-runner
  - Jaeger
  - Prometheus
  - Grafana
  - Alertmanager
  - EFK stack
  - Pritunl
  - Traefik
  - RabbitMQ
    
# Prerequisites

1. yc
2. terraform
    
# Как запустить?

1. cd terraform/prod & terraform apply