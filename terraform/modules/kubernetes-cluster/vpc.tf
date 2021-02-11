resource "yandex_vpc_route_table" "k8s-cluster-nat-route" {
  name = "${var.master.name}-nat-route"
  description = "Route all egress traffic to NAT instance"
  network_id = var.network_id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address = yandex_compute_instance.nat-instance.network_interface.0.ip_address
  }
}

resource "yandex_vpc_subnet" "k8s-cluster-nat-subnet" {
  name = "${var.master.name}-nat-subnet"
  description = "NAT subnet to allow internet access for private nodes"
  v4_cidr_blocks = var.nat.v4_cidr_blocks
  zone = var.nat.zone_id
  network_id = var.network_id
}

resource "yandex_vpc_subnet" "cluster_subnets" {
  count = length(var.cluster_subnets)
  v4_cidr_blocks = var.cluster_subnets[count.index].v4_cidr_blocks
  zone = var.cluster_subnets[count.index].zone
  network_id = var.network_id
  route_table_id = yandex_vpc_route_table.k8s-cluster-nat-route.id
  name = "${var.master.name}-subnet-${count.index}"
}