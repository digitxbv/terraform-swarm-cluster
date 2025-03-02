resource "docker_service" "prometheus" {
  name = "prom_db"
  labels {
    label = "com.docker.stack.namespace"
    value = local.stack_namespaces.prometheus
  }
  labels {
    label = "prometheus-job"
    value = "prometheus"
  }
  labels {
    label = "prometheus-job-port"
    value = "9090"
  }
  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.prom.entrypoints"
    value = "websecure"
  }
  labels {
    label = "traefik.http.routers.prom.middlewares"
    value = "admin-auth"
  }
  labels {
    label = "traefik.http.services.prom.loadbalancer.server.port"
    value = "9090"
  }
  task_spec {
    container_spec {
      labels {
        label = "com.docker.stack.namespace"
        value = local.stack_namespaces.prometheus
      }
      image = "prom/prometheus:latest"
      args = [
        "--config.file=/etc/prometheus/prometheus.yml",
        "--storage.tsdb.retention.size=5GB",
        "--storage.tsdb.retention.time=15d",
      ]
      mounts {
        target = "/prometheus"
        source = docker_volume.prometheus_data.id
        type   = "volume"
      }
      configs {
        config_id   = docker_config.prometheus_config.id
        config_name = docker_config.prometheus_config.name
        file_name   = "/etc/prometheus/prometheus.yml"
      }
    }
    networks_advanced {
      name = docker_network.socat.id
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

  depends_on = [
    docker_service.socat_manager
  ]
}

resource "docker_service" "cadvisor" {
  name = "prom_cadvisor"
  labels {
    label = "com.docker.stack.namespace"
    value = local.stack_namespaces.prometheus
  }
  labels {
    label = "prometheus-job"
    value = "cadvisor"
  }
  labels {
    label = "prometheus-job-port"
    value = "8080"
  }
  mode {
    global = true
  }
  task_spec {
    container_spec {
      labels {
        label = "com.docker.stack.namespace"
        value = local.stack_namespaces.prometheus
      }
      image = "gcr.io/cadvisor/cadvisor:v0.47.2"
      mounts {
        target    = "/var/lib/docker"
        source    = "/var/lib/docker"
        type      = "bind"
        read_only = true
      }
      mounts {
        target    = "/sys"
        source    = "/sys"
        type      = "bind"
        read_only = true
      }
      mounts {
        target = "/var/run"
        source = "/var/run"
        type   = "bind"
      }
      mounts {
        source    = "/"
        target    = "/rootfs"
        type      = "bind"
        read_only = true
      }
    }
    networks_advanced {
      name = docker_network.prometheus.id
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

resource "docker_service" "node_exporter" {
  name = "prom_node_exporter"
  labels {
    label = "com.docker.stack.namespace"
    value = local.stack_namespaces.prometheus
  }
  labels {
    label = "prometheus-job"
    value = "node-exporter"
  }
  labels {
    label = "prometheus-job-port"
    value = "9100"
  }
  mode {
    global = true
  }
  task_spec {
    container_spec {
      labels {
        label = "com.docker.stack.namespace"
        value = local.stack_namespaces.prometheus
      }
      image = "quay.io/prometheus/node-exporter:latest"
      args = [
        "--path.procfs=/host/proc",
        "--path.sysfs=/host/sys",
        "--collector.filesystem.mount-points-exclude=^/(dev|host|proc|run/credentials/.+|sys|var/lib/docker/.+)($$|/)"
      ]
      env = {
        NODE_ID = "{{.Node.ID}}",
      }
      mounts {
        source    = "/proc"
        target    = "/host/proc"
        type      = "bind"
        read_only = true
      }
      mounts {
        source    = "/sys"
        target    = "/host/sys"
        type      = "bind"
        read_only = true
      }
      mounts {
        source    = "/"
        target    = "/rootfs"
        type      = "bind"
        read_only = true
      }
      mounts {
        source = "/etc/hostname"
        target = "/etc/nodename"
        type   = "bind"
      }
    }
    networks_advanced {
      name = docker_network.prometheus.id
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

resource "docker_volume" "prometheus_data" {
  name = "prometheus_data"
}

resource "docker_config" "prometheus_config" {
  name = "prometheus_config"
  data = base64encode(file("${path.module}/configs/prometheus.yml"))
}
