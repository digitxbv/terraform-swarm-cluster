resource "docker_service" "socat_manager" {
  name = "socat_manager_app"
  labels {
    label = "com.docker.stack.namespace"
    value = local.stack_namespaces.socat
  }
  mode {
    global = true
  }
  task_spec {
    container_spec {
      labels {
        label = "com.docker.stack.namespace"
        value = local.stack_namespaces.socat
      }
      image = "alpine/socat:latest"
      args = [
        "tcp-listen:2375,fork,reuseaddr",
        "unix-connect:/var/run/docker.sock"
      ]
      mounts {
        target = "/var/run/docker.sock"
        source = "/var/run/docker.sock"
        type   = "bind"
      }
    }
    networks_advanced {
      name = docker_network.socat.id
    }
    placement {
      constraints = [
        "node.role == manager"
      ]
    }
  }

  lifecycle {
    ignore_changes = [
      task_spec[0].container_spec[0].image,
    ]
  }
}
