#-------------------------
# Discord public key
#-------------------------
resource "google_secret_manager_secret" "discord_public_key" {
  secret_id = "DISCORD_PUBLIC_KEY"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_iam_member" "discord_public_key_iam" {
  secret_id = google_secret_manager_secret.discord_public_key.id
  role      = "roles/secretmanager.secretAccessor"
  member    = google_service_account.func_discord_bot.member
}

#-------------------------
# Discord Webhook URL
#-------------------------
resource "google_secret_manager_secret" "discord_webhook_url" {
  secret_id = "DISCORD_WEBHOOK_URL"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_iam_member" "discord_webhook_url_iam" {
  secret_id = google_secret_manager_secret.discord_webhook_url.id
  role      = "roles/secretmanager.secretAccessor"
  member    = google_service_account.game_server.member
}
