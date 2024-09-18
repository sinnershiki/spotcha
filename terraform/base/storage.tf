resource "google_storage_bucket" "backup" {
  name          = "${var.project_id}-spot-game-server-backup-storage"
  storage_class = "REGIONAL"
  location      = var.region
  force_destroy = true
}

resource "google_storage_bucket_iam_member" "backup_iam" {
  bucket = google_storage_bucket.backup.name
  role   = "roles/storage.admin"
  member = google_service_account.game_server.member
}
