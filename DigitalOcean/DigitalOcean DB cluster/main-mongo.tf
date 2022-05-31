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


# Create a new MongoDB database cluster

resource "digitalocean_database_cluster" "shalom-mongo-cluster" {
  name       = "shalom-mongo-cluster"
  engine     = "mongodb"
  version    = "4"
  size       = "db-s-2vcpu-4gb"
  region     = "lon1"
  node_count = 1
}


resource "digitalocean_database_firewall" "shalom-db-fw" {
  cluster_id = digitalocean_database_cluster.shalom-mongo-cluster.id

  rule {
    type  = "ip_addr"
    value = "192.168.1.1"
  }
}





