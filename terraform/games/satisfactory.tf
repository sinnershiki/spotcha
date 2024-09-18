resource "google_compute_address" "satisfactory" {
  name         = "satisfactory"
  description  = "Global address for satisfactory"
  region       = var.region
  address_type = "EXTERNAL"
}

moved {
  from = google_dns_record_set.games
  to   = google_dns_record_set.satisfactory
}

resource "google_dns_record_set" "satisfactory" {
  managed_zone = data.google_dns_managed_zone.games.name
  name         = "satisfactory.${data.google_dns_managed_zone.games.dns_name}"
  type         = "A"
  ttl          = 60
  rrdatas      = [google_compute_address.satisfactory.address]
}

resource "google_compute_firewall" "satisfactory_allow_rule" {
  name          = "spotcha-allow-satisfactory-ports"
  description   = "Allow some udp ports for satisfactory"
  network       = data.google_compute_network.this.name
  priority      = 1000
  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  target_tags = [
    "satisfactory",
  ]

  allow {
    protocol = "udp"
    ports = [
      "15777",
      "15000",
      "7777",
    ]
  }

  allow {
    protocol = "tcp"
    ports = [
      "15777",
      "15000",
      "7777",
    ]
  }
}

resource "google_compute_instance" "satisfactory" {
  name         = "satisfactory"
  machine_type = "n2d-standard-4"
  zone         = var.zone

  tags = ["satisfactory"]

  boot_disk {
    auto_delete = true
    device_name = "satisfactory"

    initialize_params {
      image = "projects/sinnershiki/global/images/packer-satisfactory-2024-09-11"
      size  = 50
      type  = "pd-balanced"
    }
  }

  network_interface {
    network = data.google_compute_network.this.self_link
    access_config {
      nat_ip       = google_compute_address.satisfactory.address
      network_tier = "PREMIUM"
    }

    stack_type = "IPV4_ONLY"
    subnetwork = data.google_compute_subnetwork.this.self_link
  }

  scheduling {
    automatic_restart           = false
    on_host_maintenance         = "TERMINATE"
    preemptible                 = true
    provisioning_model          = "SPOT"
    instance_termination_action = "STOP"
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = data.google_service_account.game_server.email
    scopes = ["cloud-platform"]
  }

  lifecycle {
    ignore_changes = [
      network_interface[0].network,
      network_interface[0].subnetwork,
      network_interface[0].access_config[0].nat_ip,
    ]
  }
}
