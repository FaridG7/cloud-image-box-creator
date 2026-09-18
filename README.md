# Packer Vagrant Boxes

Build Vagrant-compatible Linux boxes from cloud images using [Packer](https://developer.hashicorp.com/packer), QEMU/KVM, and cloud-init.

The project is designed to turn a Linux cloud image into a reusable Vagrant `.box` with:

- QEMU/KVM virtualization
- cloud-init provisioning
- Vagrant's insecure SSH public key
- SSH-based Packer provisioning
- Cleaned cloud-init state and machine identity
- Vagrant box packaging

## Requirements

- Linux host
- [Packer](https://developer.hashicorp.com/packer)
- QEMU/KVM
- libvirt/KVM acceleration
- `make`
- A Linux cloud image with cloud-init support

Verify the required tools:

```bash
packer version
qemu-system-x86_64 --version
make --version
```

Verify that KVM is available:

```bash
ls -l /dev/kvm
```

## Project Structure

```text
.
├── templates/
│   ├── 99_vagrant.cfg
│   └── user-data.pkrtpl.hcl
├── build.pkr.hcl
├── data.pkr.hcl
├── packer.pkr.hcl
├── sources.pkr.hcl
├── variables.pkr.hcl
├── variables.auto.pkrvars.hcl.example
├── Makefile
└── .gitignore
```

### Packer configuration

- `packer.pkr.hcl` — required Packer plugins
- `sources.pkr.hcl` — QEMU source configuration
- `build.pkr.hcl` — provisioning and Vagrant packaging
- `variables.pkr.hcl` — input variable definitions
- `data.pkr.hcl` — Packer data sources
- `variables.auto.pkrvars.hcl.example` — example build configuration

### Templates

`templates/user-data.pkrtpl.hcl` creates the temporary `packer` user used during the Packer build.

`templates/99_vagrant.cfg` configures the resulting image for Vagrant, including the Vagrant user and its SSH public key.

## Usage

### 1. Clone the repository

```bash
git clone <repository-url>
cd <repository-directory>
```

### 2. Configure the build

Copy the example variables file:

```bash
cp variables.auto.pkrvars.hcl.example variables.auto.pkrvars.hcl
```

Edit it:

```hcl
vm_name   = "ubuntu-noble"
cpus      = 4
memory    = 4096
disk_size = "50G"

iso_url = "/path/to/cloud-image.img"
```

`iso_url` can point to a local cloud image.

If required, specify its checksum:

```hcl
iso_checksum = "sha256:..."
```

The default is `none`.

### 3. Initialize Packer

```bash
make init
```

### 4. Validate the configuration

```bash
make validate
```

### 5. Build the box

```bash
make build
```

The resulting Vagrant box is written to:

```text
output/<vm_name>-libvirt.box
```

The exact provider suffix is determined by Packer's Vagrant post-processor.

### Build everything

The default Make target runs initialization, validation, and the build:

```bash
make
```

## Using the Box with Vagrant

Add the generated box:

```bash
vagrant box add ./output/<box-name>.box
```

Create a `Vagrantfile`:

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "<box-name>"
end
```

Then start the VM:

```bash
vagrant up
```

## How the Build Works

The build process is approximately:

```text
Linux cloud image
       │
       ▼
    Packer
       │
       ▼
    QEMU/KVM
       │
       ▼
 cloud-init creates
 temporary packer user
       │
       ▼
 Packer connects over SSH
       │
       ▼
 Install Vagrant cloud-init configuration
       │
       ▼
 Clean cloud-init state
 Remove machine identity
       │
       ▼
 Vagrant post-processor
       │
       ▼
   .box file
```

Before packaging, the image is cleaned with:

```bash
cloud-init clean --logs --machine-id
```

The machine ID is also cleared so that a new identity can be generated when the resulting image is instantiated.

## Security Notes

This project uses the standard Vagrant insecure public key because the resulting image is intended for Vagrant development environments.

The private key used by Packer is obtained through the `sshkey` Packer data source and is not stored in the repository.

Do not use the generated Vagrant box as a production machine image without changing its authentication and provisioning model.

The following files are intentionally ignored:

```text
*.pkrvars.hcl
*.box
output/
```

This prevents local build configuration and generated boxes from being committed accidentally.

## Supported Images

The build currently assumes a Linux cloud image that:

1. Uses cloud-init.
2. Provides an SSH server.
3. Can boot under QEMU/KVM.
4. Supports the commands used during cleanup.

Different distributions may require distribution-specific cloud-init configuration or shutdown commands.

## License

Choose a license appropriate for the project before publishing, for example MIT.
