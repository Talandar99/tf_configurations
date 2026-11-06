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

variable "cloudflare_domain" {
  type = string
}

variable "cloudflare_api_token" {
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
      version = "~> 5.28"
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
  label            = "port_forwarder"
  image            = "linode/arch"
  region           = "eu-central"
  type             = "g6-nanode-1"
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

      "pacman -Sy archlinux-keyring --noconfirm",
      "pacman -Syu git docker docker-compose neovim zip wget tmux --noconfirm",

      "systemctl enable --now docker.service",

      "git clone https://github.com/Talandar99/shellfish.git /root/shellfish",

      "chmod +x /root/shellfish/scripts/install_frp.sh",
      "bash /root/shellfish/scripts/install_frp.sh",

      "echo IP---------------------------IP",
      "ip -br a",
      "echo IP---------------------------IP"
    ]
  }
}

data "cloudflare_zones" "main" {
  name   = var.cloudflare_domain
  status = "active"
}

resource "cloudflare_dns_record" "forgejo" {
  zone_id = data.cloudflare_zones.main.result[0].id

  name    = "git.${var.cloudflare_domain}"
  type    = "A"
  content = linode_instance.web.ip_address
  ttl     = 300
  proxied = false
}

resource "cloudflare_dns_record" "minecraft" {
  zone_id = data.cloudflare_zones.main.result[0].id

  name    = "minecraft.${var.cloudflare_domain}"
  type    = "A"
  content = linode_instance.web.ip_address
  ttl     = 300
  proxied = false
}
