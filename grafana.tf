resource "docker_service" "grafana" {
  name = "grafana_app"
  labels {
    label = "com.docker.stack.namespace"
    value = local.stack_namespaces.grafana
  }
  labels {
    label = "prometheus-job"
    value = "grafana"
  }
  labels {
    label = "prometheus-job-port"
    value = "3000"
  }
  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.grafana.entrypoints"
    value = "websecure"
  }
  labels {
    label = "traefik.http.services.grafana.loadbalancer.server.port"
    value = "3000"
  }
  task_spec {
    container_spec {
      labels {
        label = "com.docker.stack.namespace"
        value = local.stack_namespaces.grafana
      }
      image = "grafana/grafana:latest"
      env = {
        GF_SERVER_DOMAIN   = "${local.stack_namespaces.grafana}.${var.domain}",
        GF_SERVER_ROOT_URL = "https://${local.stack_namespaces.grafana}.${var.domain}",
      }
      mounts {
        target = "/var/lib/grafana"
        source = docker_volume.grafana_data.id
        type   = "volume"
      }
      configs {
        config_id   = docker_config.grafana_datasources.id
        config_name = docker_config.grafana_datasources.name
        file_name   = "/etc/grafana/provisioning/datasources/datasources.yml"
      }
    }
    networks_advanced {
      name = docker_network.traefik.id
    }
    networks_advanced {
      name = docker_network.prometheus.id
    }
    placement {
      constraints = [
        "node.labels.monitoring == true"
      ]
    }
  }

  lifecycle {
    ignore_changes = [
      task_spec[0].container_spec[0].image,
      task_spec[0].networks_advanced,
      task_spec[0].placement[0].platforms,
    ]
  }
}

resource "docker_volume" "grafana_data" {
  name = "grafana_data"
}

resource "docker_config" "grafana_datasources" {
  name = "grafana_datasources"
  data = base64encode(file("${path.module}/configs/datasources.yml"))
}
