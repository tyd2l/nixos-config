
### Partitioning

```sh
sudo su
# Generate keys for single password unlock
dd if=/dev/urandom of=./keyfile-root.bin bs=1024 count=4
dd if=/dev/urandom of=./keyfile-swap.bin bs=1024 count=4
```
### Setup LUKS and add the keys

```sh
cryptsetup luksFormat --type luks1 -c aes-xts-plain64 -s 256 -h sha512 /dev/nvme0n1p3

cryptsetup luksAddKey /dev/nvme0n1p3 keyfile-root.bin
cryptsetup luksOpen /dev/nvme0n1p3 crypted-nixos -d keyfile-root.bin

cryptsetup luksFormat -c aes-xts-plain64 -s 256 -h sha512 /dev/nvme0n1p2 -d keyfile-swap.bin
cryptsetup luksOpen /dev/nvme0n1p2 crypted-swap -d keyfile-swap.bin
```

### Format the partitions and mount
```sh
mkfs.fat -F 32 /dev/nvme0n1p1
mkfs.ext4 -L root /dev/mapper/crypted-nixos
mkswap -L swap /dev/mapper/crypted-swap
```

```sh
mount /dev/mapper/crypted-nixos /mnt
mkdir -p /mnt/boot/efi
mount /dev/nvme0n1p1 /mnt/boot/efi
swapon /dev/mapper/crypted-swap
```

### Copy the keys
```sh
mkdir -p /mnt/etc/secrets/initrd/
cp keyfile-root.bin keyfile-swap.bin /mnt/etc/secrets/initrd
chmod 000 /mnt/etc/secrets/initrd/keyfile*.bin
```

### Generate and edit configuration
```sh
nixos-generate-config --root /mnt
```
Sync the following with `/etc/nixos/hardware-configuration.nix`

```nix
  boot.initrd = {
    luks.devices."crypted-nixos" = {
      device = "/dev/disk/by-uuid/..."; # UUID for /dev/nvme01np3 
      keyFile = "/keyfile-root.bin";
      allowDiscards = true;
    };
    luks.devices."crypted-swap" = {
      device = "/dev/disk/by-uuid/..."; # UUID for /dev/nvme01np2 
      keyFile = "/keyfile-swap.bin";
      allowDiscards = true;
    };
    secrets = {
      "keyfile-root.bin" = "/etc/secrets/initrd/keyfile-root.bin";
      "keyfile-swap.bin" = "/etc/secrets/initrd/keyfile-swap.bin";
    };
};
```

You can get the UUIDs by running
```sh
blkid
```
### Select machine
Create ```/mnt/etc/nixos/machines/current.nix``` with:
```nix
{ config, pkgs, ... }:

{
  imports =
    [ 
	 #./desktop.nix #uncomment for desktop setup
	 #./notebook.nix #uncomment for laptop setup
    ];
}
```
### Install NixOS and reboot
```sh
nix-channel --add https://nixos.org/channels/nixos-unstable nixos
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
nixos-install
```
### If bugs with installation, do this
```sh
mkdir -p /mnt/mnt/etc
cp -r /mnt/etc/secrets /mnt/mnt/etc/
nixos-enter
ls -al /etc
```
Delete all broken symlinks, then
```sh
nix-channel --add https://nixos.org/channels/nixos-unstable nixos
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
nixos-install --root /
```