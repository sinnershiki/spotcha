#---------------
# Service Account for deploy discord bot
#---------------
resource "google_service_account" "github_deploy_discord_bot" {
  account_id   = "github-deploy-discord-bot"
  display_name = "Service account for deploy discord bot"
}

resource "google_project_iam_member" "github_deploy_discord_bot_iam" {
  for_each = toset([
    "roles/cloudfunctions.developer",
    "roles/run.admin",
  ])

  project = var.project_id
  member  = google_service_account.github_deploy_discord_bot.member
  role    = each.value
}

#---------------
# Service Account for discord bot in cloud functions
#---------------
resource "google_service_account" "func_discord_bot" {
  account_id   = "func-discord-bot"
  display_name = "Service account for discord bot in cloud functions"
}

resource "google_project_iam_member" "func_discord_bot_iam" {
  for_each = toset([
    "roles/compute.instanceAdmin",
  ])

  project = var.project_id
  member  = google_service_account.func_discord_bot.member
  role    = each.value
}

resource "google_service_account_iam_member" "func_discord_bot_as_deploy_iam" {
  service_account_id = google_service_account.func_discord_bot.id
  role               = "roles/iam.serviceAccountUser"
  member             = google_service_account.github_deploy_discord_bot.member
}

#---------------
# Service Account for game server
#---------------
resource "google_service_account" "game_server" {
  account_id   = "game-server"
  display_name = "Service account for game server"
}

resource "google_project_iam_member" "game_server_iam" {
  for_each = toset([
    "roles/monitoring.metricWriter",
    "roles/logging.logWriter"
  ])

  project = var.project_id
  member  = google_service_account.game_server.member
  role    = each.value
}
