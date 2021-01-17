# Packer LXD - Hashicorp Consul

## Build
```bash
packer build .
```

## Requirements

* packer 1.6.6 (or earlier supporting hcl2)
* a working lxd installation

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| consul\_home | n/a | `string` | `"/opt/consul"` | no |
| consul\_user | n/a | `string` | `"consul"` | no |
| source | n/a | `map(string)` | <pre>{<br>  "description": "Hashicorp Consul - Ubuntu 20.04",<br>  "image": "base-ubuntu-focal",<br>  "name": "consul-ubuntu-focal"<br>}</pre> | no |
