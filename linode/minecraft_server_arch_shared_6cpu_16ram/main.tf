variable "shellfish_repo_minecraft_version" {
  type    = string
  default = "forge_1.20.1_v47.4.26"
}

variable "linode_token" {
  type      = string
  sensitive = true
}

variable "ssh_username" {
  type      = string
  sensitive = true
}

variable "root_password" {
  type      = string
  sensitive = true
}

variable "cloudflare_api_token" {
  type      = string
  sensitive = true
}

variable "cloudflare_domain" {
  type      = string
  sensitive = true
}

terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "2.5.2"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
  }
}

provider "linode" {
  token = var.linode_token
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

resource "linode_instance" "minecraft" {
  label            = "minecraft_server_shared-6cpu-16ram"
  image            = "linode/arch"
  region           = "eu-central"
  type             = "g6-standard-6"
  authorized_users = [var.ssh_username]
  root_pass        = var.root_password
  private_ip       = false

  connection {
    type     = "ssh"
    user     = "root"
    password = var.root_password
    host     = self.ip_address
  }

  provisioner "remote-exec" {
    inline = [
      "rm -rf /usr/lib/firmware/nvidia",
      "sudo pacman -Sy archlinux-keyring --noconfirm",
      "sudo pacman -Syu git docker docker-compose neovim zip wget tmux --noconfirm",
      "sudo systemctl enable --now docker.service",
      "git clone https://github.com/Talandar99/shellfish.git",
      "cd shellfish/docker_containers/minecraft_server/${var.shellfish_repo_minecraft_version}",
      "./scripts/get_everything_and_clean.sh",
      "echo IP---------------------------IP",
      "ip a | grep inet",
      "echo IP---------------------------IP"
      //"docker compose up -d",
    ]
  }
}

data "cloudflare_zone" "minecraft" {
  name = var.cloudflare_domain
}

resource "cloudflare_record" "minecraft" {
  zone_id = data.cloudflare_zone.minecraft.id
  name    = "minecraft"
  value   = linode_instance.minecraft.ip_address
  type    = "A"
  ttl     = 300
  proxied = false
}
