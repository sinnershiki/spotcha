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
  streamcmd_version = "<steam cmd id>"
}

source "googlecompute" "corekeeper" {
  project_id   = "<Google Cloud Project>"
  zone         = "asia-northeast1-a"
  machine_type = "e2-micro"
  image_name   = "packer-corekeeper-${local.timestamp}"
  disk_size    = 10
  source_image = "packer-steamcmd-${local.streamcmd_version}"
  ssh_username = "packer"
  tags         = ["packer"]
}

build {
  sources = ["source.googlecompute.corekeeper"]

  # Doc: https://core-keeper.fandom.com/wiki/Dedicated_server
  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get -y install libxi6 xvfb",
      "sudo useradd -mrU -s /usr/sbin/nologin corekeeper-server",
      "sudo -u corekeeper-server -s /bin/bash -c \"/usr/games/steamcmd +force_install_dir /home/corekeeper-server +login anonymous +app_update 1007 validate +app_update 1963720 validate +quit\"",
      "sudo cp /home/corekeeper-server/linux64/steamclient.so /home/corekeeper-server/."
    ]
  }

  provisioner "file" {
    source      = "corekeeper-server.service"
    destination = "/tmp/corekeeper-server.service"
  }

  provisioner "file" {
    source      = "_launch.sh"
    destination = "/tmp/_launch.sh"
  }

  provisioner "shell" {
    inline = [
      "sudo mv /tmp/corekeeper-server.service /etc/systemd/system/corekeeper-server.service",
      "sudo chmod 644 /etc/systemd/system/corekeeper-server.service",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable corekeeper-server.service",
      "sudo mv /tmp/_launch.sh /home/corekeeper-server/_launch.sh",
      "sudo chmod +x /home/corekeeper-server/_launch.sh",
    ]
  }
}
