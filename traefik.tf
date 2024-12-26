resource "docker_service" "traefik" {
  name = "traefik_app"
  labels {
    label = "com.docker.stack.namespace"
    value = local.stack_namespaces.traefik
  }
  labels {
    label = "prometheus-job"
    value = "traefik"
  }
  labels {
    label = "prometheus-job-port"
    value = "8080"
  }
  labels {
    label = "traefik.http.middlewares.admin-auth.basicauth.users"
    value = local.htpasswd
  }
  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.api.entrypoints"
    value = "websecure"
  }
  labels {
    label = "traefik.http.routers.api.service"
    value = "api@internal"
  }
  labels {
    label = "traefik.http.routers.api.middlewares"
    value = "admin-auth"
  }
  labels {
    label = "traefik.http.services.api.loadbalancer.server.port"
    value = "8080"
  }
  task_spec {
    container_spec {
      labels {
        label = "com.docker.stack.namespace"
        value = local.stack_namespaces.traefik
      }
      image = "traefik:v3"
      args = [
        "--providers.swarm.endpoint=tcp://socat_manager_app:2375",
        "--providers.swarm.exposedByDefault=false",
        "--providers.swarm.network=traefik_public",
        "--providers.swarm.defaultRule=Host(`{{ index .Labels \"com.docker.stack.namespace\" }}.${var.domain}`)",
        "--entrypoints.web.address=:80",
        "--entrypoints.websecure.address=:443",
        "--entrypoints.web.http.redirections.entryPoint.to=websecure",
        "--entrypoints.web.http.redirections.entryPoint.scheme=https",
        "--entrypoints.web.http.redirections.entrypoint.permanent=true",
        "--entrypoints.websecure.forwardedHeaders.insecure=true",
        "--entrypoints.websecure.http.tls.certResolver=le",
        "--certificatesresolvers.le.acme.dnschallenge=true",
        "--certificatesresolvers.le.acme.dnschallenge.provider=scaleway",
        "--certificatesresolvers.le.acme.email=${var.acme_email}",
        "--certificatesresolvers.le.acme.storage=/certificates/acme.json",
        "--api=true",
        "--accesslog=true",
        "--metrics.prometheus=true",
      ]
      env = {
        SCW_ACCESS_KEY = var.scaleway_dns_access_key,
        SCW_SECRET_KEY = var.scaleway_dns_secret_key,
      }
      mounts {
        target = "/certificates"
        source = docker_volume.traefik_certificates.id
        type   = "volume"
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
        "node.labels.proxy == true"
      ]
    }
  }
  endpoint_spec {
    ports {
      target_port    = 80
      published_port = 80
      publish_mode   = "host"
    }
    ports {
      target_port    = 443
      published_port = 443
      publish_mode   = "host"
    }
  }

  lifecycle {
    ignore_changes = [
      task_spec[0].container_spec[0].image,
      labels
    ]
  }

  depends_on = [
    docker_service.socat_manager
  ]
}

resource "docker_volume" "traefik_certificates" {
  name = "traefik_certificates"
}
