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
  label            = "ssh_port_forwarding_tf"
  group            = "Terraform"
  image            = "linode/arch"
  region           = "eu-central"
  type             = "g6-nanode-1"
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
      # no idea why they have this garbage
      "rm -rf /usr/lib/firmware/nvidia", 
      "sudo pacman -Sy archlinux-keyring --noconfirm",
      "sudo pacman -Syu git docker docker-compose neovim zip wget tmux --noconfirm",
      "sudo systemctl enable docker.service",
      "git clone https://github.com/Talandar99/shellfish.git",
      # updating settings for port forwarding
      "echo 'GatewayPorts yes' >> /etc/ssh/sshd_config",
      "echo 'AllowTcpForwarding yes' >> /etc/ssh/sshd_config",
      "systemctl restart sshd",
      # show ip
      "echo IP---------------------------IP",
      "ip a | grep inet",
      "echo IP---------------------------IP",
      "sudo reboot",
    ]
  }
}
