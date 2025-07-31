# variables

variable "instances" {
  description = "list of vms to create"
  type = map(object({
    ip   = string
    vmid = number
  }))
  default = {
    "k3s-agent-1" = {
      ip   = "192.168.1.81/24"
      vmid = 181
    },
    "k3s-agent-2" = {
      ip   = "192.168.1.82/24"
      vmid = 182
    },
    "k3s-agent-3" = {
      ip   = "192.168.1.83/24"
      vmid = 183
    }
  }
}
variable "k3s_master_ip" {
  type    = string
  default = "192.168.1.71"
}
variable "k3s_master_token" {
  type    = string
  default = "" # your token
}
variable "ssh_username" {
  type    = string
  default = "root"
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
      source  = "Telmate/proxmox"
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
resource "proxmox_vm_qemu" "vms" {
  for_each = var.instances

  name        = each.key
  target_node = "proxmox"
  vmid        = each.value.vmid
  clone       = "debian-12-template"

  cpu {
    cores = 2
  }

  memory    = 2048
  agent     = 1
  skip_ipv6 = true

  os_type    = "cloud-init"
  ciuser     = var.ssh_username
  cipassword = var.ssh_password

  ipconfig0 = "ip=${each.value.ip},gw=192.168.1.1"

  disk {
    type    = "disk"
    size    = "10G"
    storage = "local-lvm"
    slot    = "scsi0"
  }
  disk {
    type    = "cloudinit"
    storage = "local-lvm"
    slot    = "ide2"
  }
  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0"
  }

  provisioner "remote-exec" {
    inline = [
      "apt update -y",
      "apt upgrade -y",
      "apt install iptables git tar zip unzip curl -y",
      "git clone https://github.com/Talandar99/shellfish.git",
      "curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC=\"agent\" K3S_URL=\"https://${var.k3s_master_ip}:6443\" K3S_TOKEN=\"${var.k3s_master_token}\" sh - "
    ]

    connection {
      type     = "ssh"
      user     = var.ssh_username
      password = var.ssh_password
      host     = split("/", each.value.ip)[0]
    }
  }
}
