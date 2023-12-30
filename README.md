# Terraform Swarm Okami

This Terraform project is intended to be used as a template for deploying an opinionated Swarm cluster. It provides :

* Ingress routing via Traefik preconfigured for cloudflare SSL DNS challenge for wildcard domain
* Complete monitoring with Prometheus, all next tools are already configured for being monitored
* Logging with Loki and Grafana for dashboards
* MySQL + PostgresSQL databases
* UI web managers, as Portainer, phpMyAdmin, pgAdmin

If using Hetzner as VPS provider, you can use it on top of [Terraform Hcloud Swarm](https://github.com/okami101/terraform-hcloud-swarm).
