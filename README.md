# nix-copy

Demonstrate failure of `nix copy`. 

## Tasks

### build-iso

```bash
nix build ./#packages.x86_64-linux.iso --offline
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

## Instructions

### ssh to the source machine

### Copy hello to disk

```bash
nix copy --to file://$PWD/hello github:NixOS/nixpkgs/23.11#hello --extra-experimental-features nix-command --extra-experimental-features flakes
```

### Copy from source to target

```bash
scp -r ./hello adrian@192.168.122.182:/home/adrian/hello
```

### Note the store path

```bash
nix path-info github:NixOS/nixpkgs/23.11#hello --extra-experimental-features nix-command --extra-experimental-features flakes
```

### Exit the source SSH session

### SSH into target machine and import the results of nix copy

```bash
nix copy --all --no-check-sigs --from file://$PWD/hello --extra-experimental-features nix-command --extra-experimental-features flakes
```

### run a shell with hello in the target

```bash
nix shell "<path from source machine>"
nix shell "<path from source machine>" --extra-experimental-features nix-command
hello
```

## Bisection

Since it was working in 23.11, and not in the unstable, I decided to hunt it down. I got all the commits since 23.11 with `git log --oneline | sed '/Release NixOS 23.11/q'` and bisected them.

There had been 13,269 commits since the latest, so I did a bisection search for the commit.

```
# 76090aacf4b6 - broken
# 7b2399a63c27 - working
# 140f2db977a0 - working
# 468a6bab44bf - broken
# 44f2f5ce5aaf - broken
# f9480bd35d76 - broken
# b122013b2373 - broken
# 0c909de8e6ab - broken
# 5902643e53f2 - broken
# a1e9171ca3c1 - broken
# 73b3a1450f4a - broken
# 67fc0e51da63 - broken
# 5621fb9e2dc5 - working
```

I tracked it down to here. 

```
67fc0e51da63    biome: 1.4.0 -> 1.4.1
Broken ^
5621fb9e2dc5	mosquitto: fix pkg-config files
Working ^
```
