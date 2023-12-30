terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }

  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "docker" {
  host = var.docker_host
}
