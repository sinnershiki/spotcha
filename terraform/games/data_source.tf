/*
data "google_dns_managed_zone" "spotcha" {
  name = "spotcha"
}
*/

data "google_compute_network" "this" {
  name = "spotcha-network"
}

data "google_compute_subnetwork" "this" {
  name   = "spotcha-subnet"
  region = var.region
}

data "google_service_account" "game_server" {
  account_id = "game-server"
}
