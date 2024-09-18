resource "google_compute_address" "minecraft" {
  name         = "minecraft"
  description  = "Global address for minecraft"
  region       = var.region
  address_type = "EXTERNAL"
}

resource "google_dns_record_set" "minecraft" {
  managed_zone = data.google_dns_managed_zone.games.name
  name         = "minecraft.${data.google_dns_managed_zone.games.dns_name}"
  type         = "A"
  ttl          = 60
  rrdatas      = [google_compute_address.minecraft.address]
}

resource "google_compute_firewall" "minecraft_allow_rule" {
  name          = "spotcha-allow-minecraft-ports"
  description   = "Allow some tcp ports for minecraft"
  network       = data.google_compute_network.this.name
  priority      = 1000
  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  target_tags = [
    "minecraft",
  ]

  allow {
    protocol = "tcp"
    ports = [
      "25565",
    ]
  }
}

resource "google_compute_instance" "minecraft" {
  name         = "minecraft"
  machine_type = "n2-standard-4"
  zone         = var.zone

  tags = ["minecraft"]

  boot_disk {
    auto_delete = true
    device_name = "minecraft"

    initialize_params {
      image = "projects/sinnershiki/global/images/packer-minecraft-1-21-1-2024-09-18"
      size  = 10
      type  = "pd-balanced"
    }
  }

  network_interface {
    network = data.google_compute_network.this.self_link
    access_config {
      nat_ip       = google_compute_address.minecraft.address
      network_tier = "PREMIUM"
    }

    stack_type = "IPV4_ONLY"
    subnetwork = data.google_compute_subnetwork.this.self_link
  }

  scheduling {
    automatic_restart   = false
    on_host_maintenance = "TERMINATE"
    preemptible         = true
    provisioning_model  = "SPOT"
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = data.google_service_account.game_server.email
    scopes = ["cloud-platform"]
  }
}
