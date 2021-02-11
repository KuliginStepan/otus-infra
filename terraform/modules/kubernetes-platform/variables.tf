variable "ingress_ip_address" {}

variable "openvpn" {
  type = object({
    mongodb_uri = string
    public_ip_address = string
  })
  default = {
    mongodb_uri = ""
    public_ip_address = ""
  }
}

variable "environment" {

}

variable "runner_registration_token" {}