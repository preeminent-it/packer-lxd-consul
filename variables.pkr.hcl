variable "source" {
  type = map(string)
  default = {
    description = "Hashicorp Consul - Ubuntu 20.04"
    image       = "base-ubuntu-focal"
    name        = "consul-ubuntu-focal"
  }
}

variable "consul_home" {
  type    = string
  default = "/opt/consul"
}

variable "consul_user" {
  type    = string
  default = "consul"
}
