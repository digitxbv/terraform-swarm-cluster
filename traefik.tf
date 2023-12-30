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
    value = var.http_basic_auth
  }
  labels {
    label = "traefik.http.middlewares.admin-ip.ipwhitelist.sourcerange"
    value = join(",", var.my_ip_addresses)
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
    value = "admin-ip,admin-auth"
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
      image = "traefik:v2.10"
      args = [
        "--providers.docker=true",
        "--providers.docker.exposedByDefault=false",
        "--providers.docker.network=traefik_public",
        "--providers.docker.swarmMode=true",
        "--providers.docker.defaultRule=Host(`{{ index .Labels \"com.docker.stack.namespace\" }}.${var.domain}`)",
        "--providers.docker.endpoint=tcp://socat_app:2375",
        "--entrypoints.web.address=:80",
        "--entrypoints.websecure.address=:443",
        "--entrypoints.web.http.redirections.entryPoint.to=websecure",
        "--entrypoints.web.http.redirections.entryPoint.scheme=https",
        "--entrypoints.web.http.redirections.entrypoint.permanent=true",
        "--entrypoints.websecure.forwardedHeaders.insecure=true",
        "--entrypoints.websecure.http.tls.certResolver=le",
        "--certificatesresolvers.le.acme.dnschallenge=true",
        "--certificatesresolvers.le.acme.dnschallenge.provider=cloudflare",
        "--certificatesresolvers.le.acme.email=${var.acme_email}",
        "--certificatesresolvers.le.acme.storage=/certificates/acme.json",
        "--api=true",
        "--accesslog=true",
        "--metrics.prometheus=true",
      ]
      env = {
        CLOUDFLARE_DNS_API_TOKEN = var.cloudflare_api_token,
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
        "node.role == manager"
      ]
    }
  }
  mode {
    global = true
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
}

resource "docker_volume" "traefik_certificates" {
  name = "traefik_certificates"
}
