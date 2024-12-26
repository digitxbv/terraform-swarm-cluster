# Terraform Swarm Okami

This Terraform project is intended to be used as a template for deploying an opinionated Swarm cluster. It provides :

* Ingress routing via Traefik preconfigured for Scaleway SSL DNS challenge for wildcard domain
* Complete monitoring with Prometheus, all next tools are already configured for being monitored
* Grafana for dashboards
* MySQL + PostgresSQL databases
* UI web managers, as Portainer, phpMyAdmin, pgAdmin

## Prepare cluster

If using Hetzner as VPS provider, you can use it on top of [Terraform Hcloud Swarm](https://github.com/okami101/terraform-hcloud-swarm).

Ensure to have initiated swarm cluster and update nodes with following self-explanatory labels:

```sh
docker node update --label-add manager=true swarm-manager-01
docker node update --label-add proxy=true swarm-manager-01
docker node update --label-add monitoring=true swarm-manager-01
docker node update --label-add run=true swarm-worker-01
docker node update --label-add run=true swarm-worker-02
docker node update --label-add db=true swarm-storage-01
```

Ensure to have the following docker config `/etc/docker/daemon.json` on all nodes:

```json
{
    "default-network-opts": {
        "overlay": {
            "com.docker.network.driver.mtu": "1450"
        }
    },
    "metrics-addr": "0.0.0.0:9323"
}
```

The `com.docker.network.driver.mtu` is required for avoiding MTU issues with Hetzner cloud. Use `metrics-addr` to obtain all Prometheus metrics from all services.
