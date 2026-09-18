source "qemu" "cloud-image" {
  vm_name      = "build_vm"
  iso_url      = var.iso_url
  iso_checksum = var.iso_checksum

  cpus      = var.cpus
  memory    = var.memory
  disk_size = var.disk_size

  accelerator          = "kvm"
  format               = "qcow2"
  disk_interface       = "virtio"
  iso_target_extension = "img"
  headless             = true
  disk_image           = true

  shutdown_command = "sudo -n systemctl poweroff"

  communicator              = "ssh"
  ssh_username              = "packer"
  ssh_private_key_file      = data.sshkey.packer.private_key_path
  ssh_clear_authorized_keys = true

  cd_label = "cidata"
  cd_content = {
    "meta-data" = ""
    "user-data" = templatefile("${path.root}/templates/user-data.pkrtpl.hcl", {
      ssh_public_key = data.sshkey.packer.public_key
    })
  }
}
