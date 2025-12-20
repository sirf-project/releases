# syntax=docker/dockerfile:1.19
FROM debian-base AS base

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

# Enable Non Free Repos
RUN sed -i 's/main$/main contrib non-free non-free-firmware/' /etc/apt/sources.list.d/debian.sources

# Install Core System Utilities
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    --mount=type=tmpfs,target=/var/log <<-EOF
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y console-setup dosfstools ed eject ftp hdparm info lshw netcat-openbsd netplan.io parted rsync strace sudo systemd-resolved time usbutils
EOF

# Install Kernel and Firmware
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    --mount=type=tmpfs,target=/var/log <<-EOF
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y firmware-linux-free firmware-linux-nonfree grub-efi linux-base linux-headers-generic linux-image-generic linux-perf
EOF

# Install and Configure Plymouth
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    --mount=type=tmpfs,target=/var/log <<-EOF
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y plymouth-themes
    plymouth-set-default-theme bgrt
EOF

# Install Snap and Flatpak with Flathub remote
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    --mount=type=tmpfs,target=/var/log <<-EOF
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends flatpak packagekit-tools snapd xdelta3
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
EOF

ENTRYPOINT ["/sbin/init"]
CMD ["/bin/bash", "-euxo", "pipefail"]
