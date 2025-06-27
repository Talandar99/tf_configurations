# variables

variable "archlinux_image"{
  type = string
  default = "archlinux-base_20240911-1_amd64.tar.zst"
}
variable "ssh_username" {
  type    = string
  default = "root"
}
variable "vmid" {
  type      = number
  default = 661  # unique container ID
}
variable "ssh_password" {
  type      = string
  sensitive = true
}
variable "pm_password" {
  type      = string
  sensitive = true
}

variable "pm_address" {
  type      = string
  sensitive = true
}


# providers
terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = "3.0.2-rc01"
    }
  }
}

provider "proxmox" {
  pm_api_url      = "https://${var.pm_address}:8006/api2/json"
  pm_user         = "root@pam"
  pm_password     = var.pm_password
  pm_tls_insecure = true
}
# resource
resource "proxmox_lxc" "archlinux" {
  hostname     = "proxmox-archlinux-tf-${var.vmid}"
  target_node  = "proxmox"
  vmid         =  var.vmid
  ostemplate   = "local:vztmpl/${var.archlinux_image}" 

  cores        = 6
  #memory       = 512
  #memory       = 1024
  #memory       = 2048
  #memory       = 4096
  #memory       = 8192
  memory       = 10240
  #memory       = 16384
  swap         = 512

  features {
    nesting = true
  }

  cmode         = "tty"
  tty           = 1
  unprivileged  = true
  password      = var.ssh_password 
  console       = true
  start         = true

  rootfs {
    storage  = "local-lvm"
    size     = "20G"
  }

  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "dhcp"
  }

}


resource "null_resource" "setup" {
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      host     = var.pm_address
      user     = "root"
      password = var.pm_password
    }

    inline = [
      "sleep 20",
      "lxc-attach -n ${var.vmid} -- rm -rf /etc/pacman.d/gnupg",
      "lxc-attach -n ${var.vmid} -- pacman-key --init",
      "lxc-attach -n ${var.vmid} -- pacman-key --populate archlinux",
      "lxc-attach -n ${var.vmid} -- pacman -Sy --noconfirm archlinux-keyring",
      "lxc-attach -n ${var.vmid} -- pacman -Sy git docker docker-compose neovim zip wget tmux python python-requests --noconfirm",
      "lxc-attach -n ${var.vmid} -- systemctl enable docker.service",
      "lxc-attach -n ${var.vmid} -- systemctl enable sshd",
      "lxc-attach -n ${var.vmid} -- echo 'PermitRootLogin yes' | lxc-attach -n 661 -- tee -a /etc/ssh/sshd_config > /dev/null",
      "lxc-attach -n ${var.vmid} -- echo 'PasswordAuthentication yes' | lxc-attach -n 661 -- tee -a /etc/ssh/sshd_config > /dev/null",
      "lxc-attach -n ${var.vmid} -- git clone https://github.com/Talandar99/shellfish.git",
      "echo IP---------------------------IP",
      "lxc-attach -n ${var.vmid} -- ip a | grep inet",
      "echo IP---------------------------IP",
      "lxc-attach -n ${var.vmid} -- reboot",
    ]
  }
}
