resource "docker_service" "loki" {
  name = "loki_db"
  labels {
    label = "com.docker.stack.namespace"
    value = local.stack_namespaces.loki
  }
  labels {
    label = "prometheus-job"
    value = "loki"
  }
  labels {
    label = "prometheus-job-port"
    value = "3100"
  }
  task_spec {
    container_spec {
      labels {
        label = "com.docker.stack.namespace"
        value = local.stack_namespaces.loki
      }
      image = "grafana/loki:latest"
      user  = "root"
      args = [
        "-config.file=/mnt/config/loki-config.yml",
      ]
      mounts {
        target = "/tmp/loki"
        source = docker_volume.loki_data.id
        type   = "volume"
      }
      configs {
        config_id   = docker_config.loki_config.id
        config_name = docker_config.loki_config.name
        file_name   = "/mnt/config/loki-config.yml"
      }
    }
    networks_advanced {
      name = docker_network.loki.id
    }
    networks_advanced {
      name = docker_network.prometheus.id
    }
    placement {
      constraints = [
        "node.role == manager"
      ]
    }
  }
}

resource "docker_service" "promtail" {
  name = "loki_promtail"
  labels {
    label = "com.docker.stack.namespace"
    value = local.stack_namespaces.loki
  }
  labels {
    label = "prometheus-job"
    value = "promtail"
  }
  labels {
    label = "prometheus-job-port"
    value = "9080"
  }
  mode {
    global = true
  }
  task_spec {
    container_spec {
      labels {
        label = "com.docker.stack.namespace"
        value = local.stack_namespaces.loki
      }
      image = "grafana/promtail:latest"
      args = [
        "-config.file=/mnt/config/promtail-config.yml"
      ]
      configs {
        config_id   = docker_config.promtail_config.id
        config_name = docker_config.promtail_config.name
        file_name   = "/mnt/config/promtail-config.yml"
      }
      mounts {
        target = "/var/log"
        source = "/var/log"
        type   = "bind"
      }
      mounts {
        target = "/var/lib/docker/containers"
        source = "/var/lib/docker/containers"
        type   = "bind"
      }
    }
    networks_advanced {
      name = docker_network.loki.id
    }
    networks_advanced {
      name = docker_network.prometheus.id
    }
  }
}

resource "docker_volume" "loki_data" {
  name = "loki_data"
}

resource "docker_config" "loki_config" {
  name = "loki_config"
  data = base64encode(file("${path.module}/configs/loki.yml"))
}

resource "docker_config" "promtail_config" {
  name = "promtail_config"
  data = base64encode(file("${path.module}/configs/promtail.yml"))
}
