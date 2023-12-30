# Terraform Swarm Okami

This Terraform project is intended to be used as a template for deploying an opinionated Swarm cluster. It provides :

* Ingress routing via Traefik preconfigured for cloudflare SSL DNS challenge for wildcard domain
* Complete monitoring with Prometheus, all next tools are already configured for being monitored
* Logging with Loki and Grafana for dashboards
* MySQL + PostgresSQL databases
* UI web managers, as Portainer, phpMyAdmin, pgAdmin

## Prepare cluster

If using Hetzner as VPS provider, you can use it on top of [Terraform Hcloud Swarm](https://github.com/okami101/terraform-hcloud-swarm).

Ensure to have initiated swarm cluster and update nodes with following self-explanatory labels:

```sh
docker node update --label-add type=run swarm-worker-01
docker node update --label-add type=run swarm-worker-02
docker node update --label-add type=db swarm-storage-01
```

Ensure to have the following docker config `/etc/docker/daemon.json` on all nodes:

```json
{
    "default-network-opts": {
        "overlay": {
            "com.docker.network.driver.mtu": "1450"
        }
    },
    "log-driver": "json-file",
    "log-opts": {
        "labels-regex": "^.+"
    },
    "metrics-addr": "0.0.0.0:9323"
}
```

The `com.docker.network.driver.mtu` is required for avoiding MTU issues with Hetzner cloud. Use `metrics-addr` to obtain all Prometheus metrics from all services. Logs related config allow Promtail to parse properly output docker logs in order to link them for each stack, service or tasks from Swarm.
