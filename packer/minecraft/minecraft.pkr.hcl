packer {
  required_plugins {
    googlecompute = {
      version = "1.1.6"
      source  = "github.com/hashicorp/googlecompute"
    }
  }
}

locals {
  minecraft_version          = "1.21.1"
  minecraft_version_resource = replace(local.minecraft_version, ".", "-")
  minecraft_download_url     = "https://piston-data.mojang.com/v1/objects/59353fb40c36d304f2035d51e7d6e6baa98dc05c/server.jar"
  timestamp                  = formatdate("YYYY-MM-DD", timestamp())
}

source "googlecompute" "minecraft" {
  project_id          = "<Google Cloud Project>"
  zone                = "asia-northeast1-a"
  machine_type        = "n2d-standard-2"
  image_name          = "packer-minecraft-${local.minecraft_version_resource}-${local.timestamp}"
  disk_size           = 10
  source_image_family = "ubuntu-2404-lts-amd64"
  ssh_username        = "packer"
  tags                = ["packer"]
}

build {
  sources = ["source.googlecompute.minecraft"]

  provisioner "shell" {
    inline = [
      "curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh",
      "sudo bash add-google-cloud-ops-agent-repo.sh --also-install",
    ]
  }

  provisioner "file" {
    source      = "post-message-to-discord.sh"
    destination = "/tmp/post-message-to-discord.sh"
  }

  provisioner "shell" {
    inline = [
      "sudo mkdir -p /usr/local/scripts",
      "sudo mv /tmp/post-message-to-discord.sh /usr/local/scripts/post-message-to-discord.sh",
      "sudo chmod +x /usr/local/scripts/post-message-to-discord.sh",
    ]
  }
  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y openjdk-21-jdk-headless",
      "sudo useradd -mrU -s /usr/sbin/nologin minecraft-server",
      "sudo -u minecraft-server -s /bin/bash -c \"wget -P /home/minecraft-server ${local.minecraft_download_url}\"",
      "sudo -u minecraft-server -s /bin/bash -c \"echo eula=true > /home/minecraft-server/eula.txt\""
    ]
  }

  provisioner "file" {
    source      = "server.properties"
    destination = "/tmp/server.properties"
  }

  provisioner "file" {
    source      = "minecraft-server.service"
    destination = "/tmp/minecraft-server.service"
  }

  provisioner "file" {
    source      = "startup.sh"
    destination = "/tmp/startup.sh"
  }

  provisioner "shell" {
    inline = [
      "sudo mv /tmp/server.properties /home/minecraft-server/server.properties",
      "sudo mv /tmp/minecraft-server.service /etc/systemd/system/minecraft-server.service",
      "sudo mv /tmp/startup.sh /home/minecraft-server/startup.sh",
      "sudo chown minecraft-server:minecraft-server /home/minecraft-server/server.properties",
      "sudo chown minecraft-server:minecraft-server /home/minecraft-server/startup.sh",
      "sudo chmod 644 /etc/systemd/system/minecraft-server.service",
      "sudo chmod +x /home/minecraft-server/startup.sh",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable minecraft-server",
    ]
  }
}
