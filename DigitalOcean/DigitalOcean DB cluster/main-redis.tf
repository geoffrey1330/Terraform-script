terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

# Create a new Redis database cluster

resource "digitalocean_database_cluster" "shalom-redis-cluster" {
  name       = "shalom-redis-cluster"
  engine     = "redis"
  version    = "6"
  size       = "db-s-2vcpu-4gb"
  region     = "lon1"
  node_count = 1
}


resource "digitalocean_database_firewall" "shalom-db-fw" {
  cluster_id = digitalocean_database_cluster.shalom-redis-cluster.id

  rule {
    type  = "ip_addr"
    value = "192.168.1.1"
  }
}
