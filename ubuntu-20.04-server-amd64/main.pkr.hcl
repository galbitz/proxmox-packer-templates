variable "bind_address" {
  type    = string
  default = "0.0.0.0"
}

variable "bind_max_port" {
  type    = number
  default = 9000
}

variable "bind_min_port" {
  type    = number
  default = 8000
}

variable "boot_wait" {
  type    = string
  default = "5s"
}

variable "cloud_init" {
  type    = bool
  default = true
}

variable "cloud_init_storage_pool" {
  type    = string
  default = "storage"
}

variable "cores" {
  type    = number
  default = 2
}

variable "cpu_type" {
  type    = string
  default = "host"
}

variable "datastore" {
  type    = string
  default = "storage"
}

variable "datastore_type" {
  type    = string
  default = "directory"
}

variable "disable_kvm" {
  type    = bool
  default = false
}

variable "disk_cache" {
  type    = string
  default = "none"
}

variable "disk_format" {
  type    = string
  default = "qcow2"
}

variable "disk_size" {
  type    = string
  default = "5G"
}

variable "disk_type" {
  type    = string
  default = "scsi"
}

variable "iso_checksum" {
  type    = string
  default = "d1f2bf834bbe9bb43faf16f9be992a6f3935e65be0edece1dee2aa6eb1767423"
}

variable "iso_file" {
  type    = string
  default = "ubuntu-20.04.2-live-server-amd64.iso"
}

variable "iso_storage_pool" {
  type    = string
  default = "images"
}

variable "iso_url" {
  type    = string
  default = "https://releases.ubuntu.com/20.04.2/ubuntu-20.04.2-live-server-amd64.iso"
}

variable "iso_download" {
  type    = bool
  default = true
}

variable "memory" {
  type    = number
  default = 2048
}

variable "network_adapter" {
  type    = string
  default = "vmbr0"
}

variable "network_adapter_model" {
  type    = string
  default = "virtio"
}

variable "proxmox_api_password" {
  type    = string
  default = "passw0rd"
}

variable "proxmox_api_user" {
  type    = string
  default = "user@pve"
}

variable "proxmox_host" {
  type    = string
  default = "localhost:8006"
}

variable "proxmox_insecure_tls" {
  type    = bool
  default = false
}

variable "proxmox_node_name" {
  type    = string
  default = "proxmox"
}

variable "proxmox_pool" {
  type    = string
  default = ""
}

variable "scsi_controller" {
  type    = string
  default = "virtio-scsi-pci"
}

variable "sockets" {
  type    = number
  default = 1
}

variable "ssh_timeout" {
  type    = string
  default = "15m"
}

variable "start_on_boot" {
  type    = bool
  default = false
}

variable "template_name" {
  type    = string
  default = "ubuntu-20-04-template"
}

variable "vga_memory" {
  type    = number
  default = 32
}

variable "vga_type" {
  type    = string
  default = "std"
}

variable "vmid" {
  type    = number
  default = 1000
}

locals {
  template_description = "Ubuntu 20.04, generated by packer on ${formatdate("YYYY-MM-DD hh:mm:ss", timestamp())}"
}

source "proxmox" "autogenerated_1" {
  boot                    = "order=${var.disk_type}0;ide2;net0"
  boot_command            = ["<enter><enter><f6><esc><wait> ", "autoinstall ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/", "<enter>"]
  boot_wait               = var.boot_wait
  cloud_init              = var.cloud_init
  cloud_init_storage_pool = var.cloud_init_storage_pool
  cores                   = var.cores
  cpu_type                = var.cpu_type
  disable_kvm             = var.disable_kvm
  disks {
    cache_mode        = var.disk_cache
    disk_size         = var.disk_size
    format            = var.disk_format
    storage_pool      = var.datastore
    storage_pool_type = var.datastore_type
    type              = var.disk_type
  }
  http_bind_address        = var.bind_address
  http_directory           = "./http"
  http_port_max            = var.bind_max_port
  http_port_min            = var.bind_min_port
  insecure_skip_tls_verify = var.proxmox_insecure_tls
  iso_checksum             = var.iso_checksum
  iso_file                 = var.iso_download ? "" : "${var.iso_storage_pool}:iso/${var.iso_file}"
  iso_storage_pool         = var.iso_storage_pool
  iso_url                  = var.iso_download ? var.iso_url : ""
  memory                   = var.memory
  network_adapters {
    bridge = var.network_adapter
    model  = var.network_adapter_model
  }
  node                 = var.proxmox_node_name
  onboot               = var.start_on_boot
  os                   = "l26"
  password             = var.proxmox_api_password
  pool                 = var.proxmox_pool
  proxmox_url          = "https://${var.proxmox_host}/api2/json"
  qemu_agent           = true
  scsi_controller      = var.scsi_controller
  sockets              = var.sockets
  ssh_password         = "packer"
  ssh_timeout          = var.ssh_timeout
  ssh_username         = "packer"
  template_description = local.template_description
  template_name        = var.template_name
  unmount_iso          = true
  username             = var.proxmox_api_user
  vga {
    memory = var.vga_memory
    type   = var.vga_type
  }
  vm_id   = var.vmid
  vm_name = var.template_name
}

build {
  sources = ["source.proxmox.autogenerated_1"]

  provisioner "shell" {
    execute_command = "echo 'packer' | {{ .Vars }} sudo -S -E sh -eux '{{ .Path }}'"
    inline          = ["cloud-init clean", "rm /etc/cloud/cloud.cfg.d/*", "/usr/sbin/userdel --remove --force packer"]
    skip_clean      = true
  }

}
