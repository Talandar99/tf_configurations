variable "linode_token" {
  type        = string
  sensitive   = true
}

variable "ssh_username" {
  type        = string
  sensitive   = true
}

variable "root_password" {
  type        = string
  sensitive   = true
}

terraform {
  required_providers {
    linode = {
      source = "linode/linode"
      version = "2.5.2"
    }
  }
}

provider "linode" {
        token = var.linode_token
}

resource "linode_instance" "web" {
  label            = "arch_eu-central_dedicated-4cpu-8ram-tf"
  group            = "Terraform"
  image            = "linode/arch"
  region           = "eu-central"
  type             = "g6-dedicated-4"
  authorized_users = [var.ssh_username]
  root_pass        = var.root_password
  private_ip       = false

  connection {
    type        = "ssh"
    user        = "root" 
    password    = var.root_password
    host        = self.ip_address
  }

  provisioner "remote-exec" {
    inline = [
      "rm -rf /usr/lib/firmware/nvidia", # no idea why they have this garbage
      "sudo pacman -Sy archlinux-keyring --noconfirm",
      "sudo pacman -Syu git docker docker-compose neovim zip wget tmux --noconfirm",
      "sudo systemctl enable docker.service",
      "git clone https://github.com/Talandar99/shellfish.git",
      "sudo reboot",
    ]
  }
}
