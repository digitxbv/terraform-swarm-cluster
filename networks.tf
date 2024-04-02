resource "docker_network" "socat" {
  name   = "socat_manager"
  driver = "overlay"
}

resource "docker_network" "traefik" {
  name   = "traefik_public"
  driver = "overlay"
}

resource "docker_network" "portainer_agent" {
  name   = "portainer_agent"
  driver = "overlay"
}

resource "docker_network" "prometheus" {
  name   = "prom_metrics"
  driver = "overlay"
}

resource "docker_network" "mysql" {
  name   = "mysql_db"
  driver = "overlay"
}

resource "docker_network" "postgres" {
  name   = "postgres_db"
  driver = "overlay"
}
