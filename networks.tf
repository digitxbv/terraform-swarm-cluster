resource "docker_network" "socat" {
  name   = "socat_manager"
  driver = "overlay"
}

resource "docker_network" "traefik" {
  name   = "traefik_public"
  driver = "overlay"
}

resource "docker_network" "prometheus" {
  name   = "prom_metrics"
  driver = "overlay"
}

resource "docker_network" "loki" {
  name   = "loki_logs"
  driver = "overlay"
}
