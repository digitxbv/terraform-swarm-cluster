resource "docker_service" "portainer" {
  name = "portainer_app"
  labels {
    label = "com.docker.stack.namespace"
    value = local.stack_namespaces.portainer
  }
  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.portainer.entrypoints"
    value = "websecure"
  }
  labels {
    label = "traefik.http.routers.portainer.middlewares"
    value = "admin-ip"
  }
  labels {
    label = "traefik.http.services.portainer.loadbalancer.server.port"
    value = "9000"
  }
  task_spec {
    container_spec {
      labels {
        label = "com.docker.stack.namespace"
        value = local.stack_namespaces.portainer
      }
      image = "portainer/portainer-ce:latest"
      args = [
        "-H",
        "tcp://tasks.portainer_agent:9001",
        "--tlsskipverify",
      ]
      mounts {
        target = "/data"
        source = docker_volume.portainer_data.id
        type   = "volume"
      }
    }
    networks_advanced {
      name = docker_network.portainer_agent.id
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

resource "docker_service" "portainer_agent" {
  name = "portainer_agent"
  labels {
    label = "com.docker.stack.namespace"
    value = local.stack_namespaces.portainer
  }
  mode {
    global = true
  }
  task_spec {
    container_spec {
      labels {
        label = "com.docker.stack.namespace"
        value = local.stack_namespaces.portainer
      }
      image = "portainer/agent:latest"
      mounts {
        target = "/var/run/docker.sock"
        source = "/var/run/docker.sock"
        type   = "bind"
      }
      mounts {
        target = "/var/lib/docker/volumes"
        source = "/var/lib/docker/volumes"
        type   = "bind"
      }
    }
    networks_advanced {
      name = docker_network.portainer_agent.id
    }
  }

  lifecycle {
    ignore_changes = [
      task_spec[0].container_spec[0].image,
    ]
  }
}

resource "docker_volume" "portainer_data" {
  name = "portainer_data"
}
