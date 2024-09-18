packer {
  required_plugins {
    googlecompute = {
      version = "1.1.6"
      source  = "github.com/hashicorp/googlecompute"
    }
  }
}

locals {
  timestamp         = formatdate("YYYY-MM-DD", timestamp())
  streamcmd_version = "2024-09-07"
}

source "googlecompute" "satisfactory" {
  project_id   = "<Google Cloud Project>"
  zone         = "asia-northeast1-a"
  machine_type = "n2d-standard-2"
  image_name   = "packer-satisfactory-${local.timestamp}"
  disk_size    = 50
  source_image = "packer-steamcmd-${local.streamcmd_version}"
  ssh_username = "packer"
  tags         = ["packer"]
}

build {
  sources = ["source.googlecompute.satisfactory"]

  # Doc: https://satisfactory.fandom.com/wiki/Dedicated_servers#Linux
  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get upgrade -y steamcmd",
      "sudo useradd -mrU -s /usr/sbin/nologin satisfactory-server",
      "sudo -u satisfactory-server -s /bin/bash -c \"/usr/games/steamcmd +force_install_dir /home/satisfactory-server +login anonymous +app_update 1690800 -beta public validate +quit\"",
    ]
  }

  provisioner "file" {
    source      = "satisfactory-server.service"
    destination = "/tmp/satisfactory-server.service"
  }

  provisioner "shell" {
    inline = [
      "sudo mv /tmp/satisfactory-server.service /etc/systemd/system/satisfactory-server.service",
      "sudo chmod 644 /etc/systemd/system/satisfactory-server.service",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable satisfactory-server.service",
    ]
  }
}
