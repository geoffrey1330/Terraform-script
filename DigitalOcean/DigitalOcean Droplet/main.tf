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

resource "digitalocean_ssh_key" "shalom_ssh_key" {
  name       = "Droplet SSH key"
  public_key = file("/Users/apple/.ssh/id_rsa.pub")
}

resource "digitalocean_droplet" "shalom-droplet" {
  image              = "ubuntu-18-04-x64"
  name               = "shalom-droplet"
  region             = "lon1"
  size               = "s-2vcpu-4gb"
  monitoring         = true
  private_networking = true
  ssh_keys = [
    digitalocean_ssh_key.shalom_ssh_key.id
  ]
  user_data = file("${path.module}/files/user-data.sh")
}
