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

provider "kubernetes" {
  host  = resource.digitalocean_kubernetes_cluster.k8s.endpoint
  token = resource.digitalocean_kubernetes_cluster.k8s.kube_config[0].token
  cluster_ca_certificate = base64decode(
    resource.digitalocean_kubernetes_cluster.k8s.kube_config[0].cluster_ca_certificate
  )
}

resource "digitalocean_kubernetes_cluster" "shalom-k8s" {
  name   = "shalom-k8s"
  region = "lon1"
  version = "1.22.8-do.1"

  node_pool {
    name = "${var.name}-worker-pool"

    # doctl kubernetes options sizes
    size       = "s-2vcpu-4gb"
    node_count = 2
  }
}
