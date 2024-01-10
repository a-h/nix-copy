# nix-copy

Demonstrate failure of `nix copy`. 

## Tasks

### build-iso

```bash
nix build ./#packages.x86_64-linux.iso 
```

### virt-run-all

Env: LIBVIRT_DEFAULT_URI=qemu:///system

Copy the image from the read-only Nix store to the local directory, and run it.

```bash
sudo mkdir -p /vm
sudo cp -L ./result/nixos.qcow2 /vm/source.qcow2
sudo cp -L ./result/nixos.qcow2 /vm/target.qcow2
sudo chmod 766 /vm/source.qcow2
sudo chmod 766 /vm/target.qcow2
sudo chmod 755 /vm
sudo chown -R libvirt-qemu:libvirt-qemu /vm
virt-install --name source --memory 2048 --vcpus 1 --disk /vm/source.qcow2,bus=sata --import --os-variant nixos-unknown --network default --noautoconsole
virt-install --name target --memory 2048 --vcpus 1 --disk /vm/target.qcow2,bus=sata --import --os-variant nixos-unknown --network default --noautoconsole
```

### virt-list

Env: LIBVIRT_DEFAULT_URI=qemu:///system

```bash
virsh list --all
```

### virt-kill

Shutdown with virtsh shutdown, or in this case, completely remove it with undefine.

Env: LIBVIRT_DEFAULT_URI=qemu:///system

```bash
virsh destroy source || true
virsh undefine source --remove-all-storage || true
virsh destroy target || true
virsh undefine target --remove-all-storage || true
```

### virt-ssh

Env: LIBVIRT_DEFAULT_URI=qemu:///system

https://www.cyberciti.biz/faq/find-ip-address-of-linux-kvm-guest-virtual-machine/

```bash
virsh domifaddr source | virsh-json | jq -r ".[0].Address"
virsh domifaddr target | virsh-json | jq -r ".[0].Address"
```
