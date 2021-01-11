bind_addr              = "{{ GetInterfaceIP \"eth0\" }}"
server                 = true

acl = {
  enabled                  = true
  default_policy           = "allow"
  enable_token_persistence = true
}

ports = {
  http  = -1
  https = 8501
}

datacenter             = "dc1"
data_dir               = "/opt/consul"
encrypt                = "qDOPBEr+/oUVeOFQOnVypxwDaHzLrD+lvjo5vCEBbZ0="
#ca_file                = "/etc/consul/tls/consul-agent-ca.pem"
cert_file              = "/etc/consul/tls/server.crt"
key_file               = "/etc/consul/tls/server.key"
verify_incoming        = true
verify_outgoing        = true
verify_server_hostname = true
