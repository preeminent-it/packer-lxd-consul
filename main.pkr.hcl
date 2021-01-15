// Variables
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

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

// Image
source "lxd" "main" {
  image        = "${var.source.image}"
  output_image = "${var.source.name}"
  publish_properties = {
    description = "${var.source.description}"
  }
}

// Build
build {
  sources = ["source.lxd.main"]

  // Create self-signed certificate
  provisioner "shell" {
    inline = [
      "openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes -keyout /etc/consul/tls/server.key -out /etc/consul/tls/server.crt -subj \"/CN=consul\""
    ]
  }

  // Add Consul config
  provisioner "file" {
    source      = "files/etc/consul/consul.hcl"
    destination = "/etc/consul/consul.hcl"
  }

  // Add Consul service
  provisioner "file" {
    source      = "files/etc/systemd/system/consul.service"
    destination = "/etc/systemd/system/consul.service"
  }

  // Set file ownership and enable the service
  provisioner "shell" {
    inline = [
      "chown -R ${var.consul_user} /etc/consul ${var.consul_home}",
      "systemctl enable consul"
    ]
  }
}
