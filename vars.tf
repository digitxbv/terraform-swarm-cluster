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

variable "default_user" {
  description = "Default user"
  type        = string
}

variable "default_email" {
  description = "Default user email"
  type        = string
}

variable "mysql_root_password" {
  description = "MySQL root password"
  type        = string
  sensitive   = true
}

variable "mysql_password" {
  description = "MySQL user password"
  type        = string
  sensitive   = true
}

variable "postgres_password" {
  description = "PostgreSQL password"
  type        = string
  sensitive   = true
}
