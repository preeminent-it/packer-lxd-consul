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

  // Add Consul config
  provisioner "file" {
    source      = "files/etc/consul"
    destination = "/etc/"
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

  // Defaults for Consul Template
  provisioner "file" {
    source      = "files/etc/default/consul-template"
    destination = "/etc/default/consul-template"
  }

}
