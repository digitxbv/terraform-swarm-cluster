resource "docker_service" "socat" {
  name = "socat_app"
  labels {
    label = "com.docker.stack.namespace"
    value = local.stack_namespaces.socat
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
  mode {
    global = true
  }
}
