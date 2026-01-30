variable "linode_token" {
  type      = string
  sensitive = true
}

variable "ssh_username" {
  type = string
}

variable "root_password" {
  type = string
}

variable "bootstrap_pubkey" {
  type = string
}

variable "bootstrap_privkey_b64" {
  type = string
}

terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "2.5.2"
    }
  }
}

provider "linode" {
  token = var.linode_token
}

locals {
  nodes = toset(["01", "02", "03", "04", "05"])
}

resource "linode_instance" "web" {
  for_each = local.nodes

  label            = "arch_eu-central_nanode-1cpu-1ram_tf-${each.key}"
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
      #"mkdir -p /root/.ssh",
      #"chmod 700 /root/.ssh",

      #"echo '${var.bootstrap_privkey_b64}' | base64 -d > /root/.ssh/id_ed25519",
      #"chmod 600 /root/.ssh/id_ed25519",

      #"touch /root/.ssh/authorized_keys",
      #"chmod 600 /root/.ssh/authorized_keys",
      #"grep -qxF '${var.bootstrap_pubkey}' /root/.ssh/authorized_keys || echo '${var.bootstrap_pubkey}' >> /root/.ssh/authorized_keys",

      "rm -rf /usr/lib/firmware/nvidia",
      "pacman -Sy archlinux-keyring --noconfirm",
      "pacman -Syu git docker docker-compose neovim zip wget tmux openssh --noconfirm",
      "systemctl enable --now sshd",
      "systemctl enable --now docker.service",

      "git clone https://github.com/Talandar99/shellfish.git || true",
      "curl -sfL https://get.k3s.io | sh -",
      "reboot",
    ]
  }
}
