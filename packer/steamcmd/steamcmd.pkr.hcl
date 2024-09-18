packer {
  required_plugins {
    googlecompute = {
      version = "1.1.6"
      source  = "github.com/hashicorp/googlecompute"
    }
  }
}

locals {
  timestamp = formatdate("YYYY-MM-DD", timestamp())
}

source "googlecompute" "steamcmd" {
  project_id          = "<Google Cloud Project>"
  zone                = "asia-northeast1-a"
  machine_type        = "e2-micro"
  image_name          = "packer-steamcmd-${local.timestamp}"
  disk_size           = 10
  source_image_family = "ubuntu-2404-lts-amd64"
  ssh_username        = "packer"
  tags                = ["packer"]
}

build {
  sources = ["source.googlecompute.steamcmd"]

  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo add-apt-repository -y multiverse; sudo dpkg --add-architecture i386; sudo apt-get update",
      "echo steam steam/question select \"I AGREE\" | sudo debconf-set-selections",
      "echo steam steam/license note '' | sudo debconf-set-selections",
      "DEBIAN_FRONTEND=noninteractive sudo apt-get -y install steamcmd",
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
      "curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh",
      "sudo bash add-google-cloud-ops-agent-repo.sh --also-install",
    ]
  }
}
