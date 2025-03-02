resource "docker_service" "mysql" {
  name = "mysql_db"
  labels {
    label = "com.docker.stack.namespace"
    value = local.stack_namespaces.mysql
  }
  task_spec {
    container_spec {
      labels {
        label = "com.docker.stack.namespace"
        value = local.stack_namespaces.mysql
      }
      image = "mysql:8"
      env = {
        MYSQL_ROOT_PASSWORD = var.mysql_root_password,
        MYSQL_DATABASE      = var.default_user,
        MYSQL_USER          = var.default_user,
        MYSQL_PASSWORD      = var.mysql_password,
      }
      mounts {
        target = "/var/lib/mysql"
        source = docker_volume.mysql_data.id
        type   = "volume"
      }
    }
    networks_advanced {
      name = docker_network.mysql.id
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
      task_spec[0].networks_advanced,
      task_spec[0].placement[0].platforms,
    ]
  }
}

resource "docker_service" "mysql_exporter" {
  name = "mysql_exporter"
  labels {
    label = "com.docker.stack.namespace"
    value = local.stack_namespaces.mysql
  }
  labels {
    label = "prometheus-job"
    value = "mysql"
  }
  labels {
    label = "prometheus-job-port"
    value = "9104"
  }
  task_spec {
    container_spec {
      labels {
        label = "com.docker.stack.namespace"
        value = local.stack_namespaces.mysql
      }
      image = "prom/mysqld-exporter:latest"
      args = [
        "--mysqld.address=db:3306",
        "--mysqld.username=root"
      ]
      env = {
        MYSQLD_EXPORTER_PASSWORD = var.default_user,
      }
    }
    networks_advanced {
      name = docker_network.mysql.id
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
      task_spec[0].networks_advanced,
      task_spec[0].placement[0].platforms,
    ]
  }
}

resource "docker_service" "phpmyadmin" {
  name = "pma_app"
  labels {
    label = "com.docker.stack.namespace"
    value = local.stack_namespaces.phpmyadmin
  }
  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.phpmyadmin.entrypoints"
    value = "websecure"
  }
  labels {
    label = "traefik.http.services.phpmyadmin.loadbalancer.server.port"
    value = "80"
  }
  task_spec {
    container_spec {
      labels {
        label = "com.docker.stack.namespace"
        value = local.stack_namespaces.phpmyadmin
      }
      image = "phpmyadmin/phpmyadmin:latest"
      env = {
        MYSQL_ROOT_PASSWORD = var.default_user,
        PMA_HOST            = "mysql_db",
        UPLOAD_LIMIT        = "1G",
      }
    }
    networks_advanced {
      name = docker_network.mysql.id
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
      task_spec[0].networks_advanced,
      task_spec[0].placement[0].platforms,
    ]
  }
}

resource "docker_volume" "mysql_data" {
  name = "mysql_data"
}
