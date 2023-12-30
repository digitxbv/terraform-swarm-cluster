variable "docker_host" {
  type = string
}

variable "domain" {
  type = string
}

variable "acme_email" {
  type = string
}

variable "cloudflare_api_token" {
  type      = string
  sensitive = true
}

variable "http_basic_auth" {
  type      = string
  sensitive = true
}

variable "my_ip_addresses" {
  description = "Your public IP addresses for internal tools whitelist"
  type        = list(string)
  sensitive   = true
  default = [
    "0.0.0.0/0",
    "::/0"
  ]
}
