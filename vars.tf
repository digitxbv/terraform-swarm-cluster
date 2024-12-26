variable "docker_host" {
  type = string
}

variable "domain" {
  type = string
}

variable "acme_email" {
  type = string
}

variable "scaleway_dns_access_key" {
  type = string
}

variable "scaleway_dns_secret_key" {
  type      = string
  sensitive = true
}

variable "http_basic_password" {
  type      = string
  sensitive = true
}

variable "default_user" {
  description = "Default user"
  type        = string
}

variable "default_email" {
  description = "Default user email"
  type        = string
}

variable "default_pgadmin_password" {
  description = "Default PgAdmin password"
  type        = string
  sensitive   = true
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
