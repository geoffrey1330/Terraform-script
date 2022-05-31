terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_ssh_key" "web_ssh_key" {
  name       = "Droplet SSH key"
  public_key = file("/Users/apple/.ssh/id_rsa.pub")
}

resource "digitalocean_droplet" "web-droplet" {
  count              = 2
  image              = "ubuntu-18-04-x64"
  name               = "web-droplet${count.index}"
  region             = var.region
  size               = "s-2vcpu-4gb"
  monitoring         = true
  private_networking = true
  ssh_keys = [
    digitalocean_ssh_key.web_ssh_key.id
  ]
  user_data = file("${path.module}/files/user-data.sh")
}

resource "digitalocean_certificate" "web_certificate" {
  name    = "web_certificate"
  type    = "lets_encrypt"
  domains = ["web_domain.com"]
}

resource "digitalocean_loadbalancer" "web_loadbalancer" {
  name   = "web_loadbalancer"
  region = var.region

  forwarding_rule {
    entry_port     = 80
    entry_protocol = "http"

    target_port     = 8080
    target_protocol = "http"
  }
  
  forwarding_rule {
    entry_port     = 443
    entry_protocol = "https"

    target_port     = 8080
    target_protocol = "http"

    certificate_id = digitalocean_certificate.web_certificate.id
  }

  healthcheck {
    port     = 22
    protocol = "http"
    path     = "/"
  }
  redirect_http_to_https = true
  droplet_ids = digitalocean_droplet.web_droplet.*.id
}

resource "digitalocean_firewall" "web_firewall" {
  name = "web-droplet-firewall"

  droplet_ids = digitalocean_droplet.web_droplet.*.id 

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol                  = "tcp"
    port_range                = "8080"
    source_load_balancer_uids = [digitalocean_loadbalancer.web_loadbalancer.id]
  }

  inbound_rule {
    protocol         = "icmp"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}


resource "digitalocean_domain" "web_domain" {
  name = "web_domain.com"
}

resource "digitalocean_record" "web_record" {
  domain = digitalocean_domain.web_domain.name
  type   = "A"
  name   = "@"
  value  = digitalocean_loadbalancer.web_loadbalancer.ip
}