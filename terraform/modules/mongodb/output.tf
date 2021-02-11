output "hosts_string" {
  value = join(",", formatlist("%s:27018", yandex_mdb_mongodb_cluster.mongodb_cluster.host.*.name))
}

output "users" {
  value = tolist(yandex_mdb_mongodb_cluster.mongodb_cluster.user)
}