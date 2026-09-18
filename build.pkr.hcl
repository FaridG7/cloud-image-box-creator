build {
  sources = ["source.qemu.cloud-image"]

  provisioner "file" {
    source      = "${path.root}/templates/99_vagrant.cfg"
    destination = "/tmp/99_vagrant.cfg"
  }

  provisioner "shell" {
    inline = ["sudo mv /tmp/99_vagrant.cfg /etc/cloud/cloud.cfg.d/99_vagrant.cfg"]
  }

  provisioner "shell" {
    inline = [
      "sudo cloud-init clean --logs --machine-id",
      "sudo truncate -s 0 /etc/machine-id",
      "sudo rm -rf /var/lib/cloud/"
    ]
  }

  post-processor "vagrant" {
    output = "${path.root}/output/${var.vm_name}-{{.Provider}}.box"
  }
}
