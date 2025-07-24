# variables

variable "instances" {
  description = "list of vms to create"
  type = map(object({
    ip   = string
    vmid = number
  }))
  default = {
    "node1" = {
      ip   = "192.168.1.71/24"
      vmid = 671
    }
  }
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
    size    = "512M"
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
      "apt install git tar zip unzip",
      "git clone https://github.com/Talandar99/shellfish.git"
    ]

    connection {
      type     = "ssh"
      user     = var.ssh_username
      password = var.ssh_password
      host     = split("/", each.value.ip)[0]
    }
  }
}
