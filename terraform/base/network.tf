#---------------
# Create a network and subnetwork for the project
#---------------
resource "google_compute_network" "this" {
  name                            = "spotcha-network"
  auto_create_subnetworks         = false
  routing_mode                    = "GLOBAL"
  delete_default_routes_on_create = true
}

resource "google_compute_subnetwork" "this" {
  name                     = "spotcha-subnet"
  ip_cidr_range            = "10.0.0.0/16"
  network                  = google_compute_network.this.self_link
  private_ip_google_access = true
}

resource "google_compute_route" "default_route" {
  name             = "spotcha-default-route"
  description      = "Default route to the Internet."
  dest_range       = "0.0.0.0/0"
  network          = google_compute_network.this.self_link
  next_hop_gateway = "projects/${var.project_id}/global/gateways/default-internet-gateway"
  priority         = 1000
}

#---------------
# Firewall rules
#---------------
resource "google_compute_firewall" "iap_ssh_allow_rule" {
  name          = "spotcha-allow-iap-ssh"
  description   = "Allow iap ssh ports for satisfactory"
  network       = google_compute_network.this.name
  priority      = 1000
  direction     = "INGRESS"
  source_ranges = ["35.235.240.0/20"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_firewall" "icmp_allow_rule" {
  name          = "spotcha-allow-icmp"
  description   = "Allow icmp"
  network       = google_compute_network.this.name
  priority      = 1000
  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "icmp"
  }
}

resource "google_compute_firewall" "packer_ssh_allow_rule" {
  name          = "spotcha-allow-packer-ssh"
  description   = "Allow ssh ports for packer"
  network       = google_compute_network.this.name
  priority      = 1000
  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  target_tags = [
    "packer",
  ]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}
