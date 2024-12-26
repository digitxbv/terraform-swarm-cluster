resource "docker_service" "postgres" {
  name = "postgres_db"
  labels {
    label = "com.docker.stack.namespace"
    value = local.stack_namespaces.postgres
  }
  task_spec {
    container_spec {
      labels {
        label = "com.docker.stack.namespace"
        value = local.stack_namespaces.postgres
      }
      image = "postgres:16"
      args = [
        "-c",
        "max_connections=500",
        # "log_statement=all",
      ]
      env = {
        POSTGRES_DB       = var.default_user,
        POSTGRES_USER     = var.default_user,
        POSTGRES_PASSWORD = var.postgres_password,
      }
      mounts {
        target = "/var/lib/postgresql/data"
        source = docker_volume.postgres_data.id
        type   = "volume"
      }
    }
    networks_advanced {
      name = docker_network.postgres.id
    }
    placement {
      constraints = [
        "node.labels.db == true"
      ]
    }
  }

  lifecycle {
    ignore_changes = [
      task_spec[0].container_spec[0].image,
    ]
  }
}

resource "docker_service" "postgres_exporter" {
  name = "postgres_exporter"
  labels {
    label = "com.docker.stack.namespace"
    value = local.stack_namespaces.postgres
  }
  labels {
    label = "prometheus-job"
    value = "postgres"
  }
  labels {
    label = "prometheus-job-port"
    value = "9187"
  }
  task_spec {
    container_spec {
      labels {
        label = "com.docker.stack.namespace"
        value = local.stack_namespaces.postgres
      }
      image = "quay.io/prometheuscommunity/postgres-exporter:latest"
      env = {
        DATA_SOURCE_URI  = "postgres_db/postgres?sslmode=disable",
        DATA_SOURCE_USER = var.default_user,
        DATA_SOURCE_PASS = var.default_user,
      }
    }
    networks_advanced {
      name = docker_network.postgres.id
    }
    networks_advanced {
      name = docker_network.prometheus.id
    }
    placement {
      constraints = [
        "node.labels.db == true"
      ]
    }
  }

  lifecycle {
    ignore_changes = [
      task_spec[0].container_spec[0].image,
    ]
  }
}

resource "docker_service" "pgadmin" {
  name = "pga_app"
  labels {
    label = "com.docker.stack.namespace"
    value = local.stack_namespaces.pgadmin
  }
  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.pgadmin.entrypoints"
    value = "websecure"
  }
  labels {
    label = "traefik.http.services.pgadmin.loadbalancer.server.port"
    value = "80"
  }
  task_spec {
    container_spec {
      labels {
        label = "com.docker.stack.namespace"
        value = local.stack_namespaces.pgadmin
      }
      image = "dpage/pgadmin4:latest"
      env = {
        PGADMIN_DEFAULT_EMAIL    = var.default_email,
        PGADMIN_DEFAULT_PASSWORD = var.default_pgadmin_password,
      }
      mounts {
        target = "/var/lib/pgadmin"
        source = docker_volume.pgadmin_data.id
        type   = "volume"
      }
    }
    networks_advanced {
      name = docker_network.postgres.id
    }
    networks_advanced {
      name = docker_network.traefik.id
    }
    placement {
      constraints = [
        "node.labels.manager == true"
      ]
    }
  }

  lifecycle {
    ignore_changes = [
      task_spec[0].container_spec[0].image,
    ]
  }
}

resource "docker_volume" "postgres_data" {
  name = "postgres_data"
}

resource "docker_volume" "pgadmin_data" {
  name = "pgadmin_data"
}
