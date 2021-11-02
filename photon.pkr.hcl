
# reference https://github.com/vmware/photon-packer-templates

packer {
  required_version = ">= 1.7.0"
}

variable "iso_file_checksum" {
  type    = string
  default = "sha1:bec6359661b43ff15ac02b037f8028ae116dadb3"
}

variable "iso_filename" {
  type    = string
  default = "https://packages.vmware.com/photon/4.0/Rev1/iso/photon-4.0-ca7c9e933.iso"
}

variable "user_password" {
  type    = string
  default = "packer"
}

variable "user_username" {
  type    = string
  default = "root"
}

variable "cpu_count" {
  type    = number
  default = "2"
}

variable "ram_gb" {
  type    = number
  default = "6"
}

variable "boot_key_interval_iso" {
  type    = string
  default = "30ms"
}

variable "boot_wait_iso" {
  type    = string
  default = "3s"
}

variable "boot_keygroup_interval_iso" {
  type    = string
  default = "1s"
}

variable "fusion_path" {
  type    = string
  default = "/Applications/VMware Fusion.app"
}

variable "guest_os" {
  type    = string
  default = "vmware-photon-64"
}

variable "vhw_version" {
  type    = string
  default = "19"
}

# source from iso
source "vmware-iso" "photon" {
  fusion_app_path      = var.fusion_path
  display_name         = "{{build_name}}"
  vm_name              = "{{build_name}}"
  vmdk_name            = "{{build_name}}"
  iso_url              = "${var.iso_filename}"
  iso_checksum         = "${var.iso_file_checksum}"
  output_directory     = "output/{{build_name}}"
  ssh_username         = "${var.user_username}"
  ssh_password         = "${var.user_password}"
  shutdown_command     = "sudo shutdown -h now"
  guest_os_type        = var.guest_os
  cdrom_adapter_type   = "sata"
  disk_size            = "100000"
  disk_adapter_type    = "nvme"
  http_directory       = "http"
  network_adapter_type = "vmxnet3"
  disk_type_id         = "0"
  ssh_timeout          = "12h"
  usb                  = "true"
  version              = var.vhw_version
  cpus                 = var.cpu_count
  cores                = var.cpu_count
  memory               = var.ram_gb * 1024
  vmx_data = {
    "ulm.disableMitigations" = "TRUE",
    "firmware"               = "efi",
    "svga.vramSize" = "134217728"
  }
  boot_wait              = var.boot_wait_iso
  boot_key_interval      = var.boot_key_interval_iso
  boot_keygroup_interval = var.boot_keygroup_interval_iso
  boot_command = [
    "c",
    "linux /isolinux/vmlinuz root=/dev/ram0 loglevel=3 photon.media=UUID=$photondisk insecure_installation=1 ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/kickstart.json<enter>",
    "initrd /isolinux/initrd.img <enter>",
    "boot<enter>"
  ]
}
# Base build
build {
  #  name = "base"
  sources = [
    "sources.vmware-iso.photon"
  ]

    provisioner "file" {
    sources     = ["files/config.json"]
    destination = "~/"
  }

    provisioner "shell" {
    script            = "scripts/configure.sh"
  }
}
