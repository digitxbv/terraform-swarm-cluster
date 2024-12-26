resource "docker_network" "socat" {
  name   = "socat_manager"
  driver = "overlay"

  ipam_config {
    subnet  = "10.1.0.0/24"
    gateway = "10.1.0.1"
  }
}

resource "docker_network" "traefik" {
  name   = "traefik_public"
  driver = "overlay"

  ipam_config {
    subnet  = "10.2.0.0/24"
    gateway = "10.2.0.1"
  }
}

resource "docker_network" "portainer_agent" {
  name   = "portainer_agent"
  driver = "overlay"

  ipam_config {
    subnet  = "10.3.0.0/24"
    gateway = "10.3.0.1"
  }
}

resource "docker_network" "prometheus" {
  name   = "prom_metrics"
  driver = "overlay"

  ipam_config {
    subnet  = "10.4.0.0/24"
    gateway = "10.4.0.1"
  }
}

resource "docker_network" "mysql" {
  name   = "mysql_db"
  driver = "overlay"

  ipam_config {
    subnet  = "10.5.0.0/24"
    gateway = "10.5.0.1"
  }
}

resource "docker_network" "postgres" {
  name   = "postgres_db"
  driver = "overlay"

  ipam_config {
    subnet  = "10.6.0.0/24"
    gateway = "10.6.0.1"
  }
}
