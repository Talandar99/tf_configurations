variable "shellfish_repo_minecraft_version" {
  type    = string
  default = "vanilla_1.21.7"
}
variable "minecraft_data_location" {
  type    = string
  default = "/home/talandar/backups/minecraft/data_maria_miasto_02.tar.xz"
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

resource "linode_instance" "web" {
  label            = "minecraft_server"
  image            = "linode/arch"
  region           = "eu-central"
  type             = "g6-dedicated-4"
  authorized_users = [var.ssh_username]
  root_pass        = var.root_password
  private_ip       = false

  connection {
    type     = "ssh"
    user     = "root"
    password = var.root_password
    host     = self.ip_address

  }

  provisioner "file" {
    source      = var.minecraft_data_location
    destination = "/root/data.tar.xz"
  }


  provisioner "remote-exec" {
    inline = [
      "rm -rf /usr/lib/firmware/nvidia", # no idea why they have this garbage
      "sudo pacman -Sy archlinux-keyring --noconfirm",
      "sudo pacman -Sy git docker docker-compose neovim zip wget tmux --noconfirm",
      "sudo systemctl enable docker.service",
      "sudo systemctl start docker.service",
      "git clone https://github.com/Talandar99/shellfish.git",
      "cd shellfish/docker_containers/minecraft_server/${var.shellfish_repo_minecraft_version}",
      "cp /root/data.tar.xz .",
      "tar xvJf data.tar.xz",
      "docker compose up -d",
      # show ip
      "echo IP---------------------------IP",
      "ip -br a",
      "echo IP---------------------------IP",
    ]
  }

}
# addding domain

data "cloudflare_zone" "myzone" {
  name = var.cloudflare_domain
}

resource "cloudflare_record" "minecraft" {
  zone_id = data.cloudflare_zone.myzone.id
  name    = "minecraft"
  value   = linode_instance.web.ip_address
  type    = "A"
  ttl     = 300
  proxied = false
}
