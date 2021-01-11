// Variables
variable "packages" {
  type    = list(string)
  default = [
    "curl",
    "unzip"
  ]
}

variable "node_exporter_version" {
  type    = string
  default = "1.0.1"
}

variable "consul_home" {
  type    = string
  default = "/opt/consul"
}

variable "consul_version" {
  type    = string
  default = "1.9.1"
}

variable "consul_user" {
  type    = string
  default = "consul"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

// Image
source "lxd" "consul-ubuntu-focal" {
  image        = "images:ubuntu/focal"
  output_image = "consul-ubuntu-focal"
  publish_properties = {
    description = "Hashicorp Consul - Ubuntu Focal"
  }
}

// Build
build {
  sources = ["source.lxd.consul-ubuntu-focal"]

  // Update and install packages
  provisioner "shell" {
    inline = [
      "apt-get update -qq",
      "DEBIAN_FRONTEND=noninteractive apt-get install -qq ${join(" ", var.packages)} < /dev/null > /dev/null"
    ]
  }

  // Install node_exporter
  provisioner "shell" {
    inline = [
      "curl -sLo - https://github.com/prometheus/node_exporter/releases/download/v${var.node_exporter_version}/node_exporter-${var.node_exporter_version}.linux-amd64.tar.gz | \n",
      "tar -zxf - --strip-component=1 -C /usr/local/bin/ node_exporter-${var.node_exporter_version}.linux-amd64/node_exporter"
    ]
  }

  // Create directories for Consul
  provisioner "shell" {
    inline = [
      "mkdir -p /etc/consul/tls ${var.consul_home}"
    ]
  }

  // Create Consul system user
  provisioner "shell" {
    inline = [
      "useradd --system --home ${var.consul_home} --shell /bin/false ${var.consul_user}"
    ]
  }

  // Create self-signed certificate
  provisioner "shell" {
    inline = [
      "openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes -keyout /etc/consul/tls/server.key -out /etc/consul/tls/server.crt -subj \"/CN=consul\""
    ]
  }

  // Install Consul
  provisioner "shell" {
    inline = [
      "curl -sO https://releases.hashicorp.com/consul/${var.consul_version}/consul_${var.consul_version}_linux_amd64.zip &&",
      "unzip consul_${var.consul_version}_linux_amd64.zip consul -d /usr/local/bin/ &&",
      "rm consul_${var.consul_version}_linux_amd64.zip"
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
