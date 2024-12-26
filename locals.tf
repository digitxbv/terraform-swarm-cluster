resource "random_password" "salt" {
  length  = 16
  special = true
}

locals {
  stack_namespaces = {
    socat      = "socat"
    traefik    = "traefik"
    prometheus = "prom"
    grafana    = "grafana"
    pgadmin    = "pga"
    phpmyadmin = "pma"
    mysql      = "mysql"
    postgres   = "postgres"
    portainer  = "portainer"
  }
  salt     = random_password.salt.result
  htpasswd = "${var.default_user}:${bcrypt(var.http_basic_password)}"
}
