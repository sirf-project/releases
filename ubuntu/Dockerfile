# syntax=docker/dockerfile:1.19
FROM ubuntu-base AS base

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

# Delete the default ubuntu user to avoid conflicts
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    --mount=type=tmpfs,target=/var/log <<-EOF
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends perl adduser
    deluser --remove-home ubuntu
    apt-get purge -y --auto-remove perl adduser
EOF

# Install Ubuntu Minimal and Standard
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    --mount=type=tmpfs,target=/var/log <<-EOF
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y ubuntu-minimal ubuntu-standard
EOF

# Install Kernel and Bootloader
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    --mount=type=tmpfs,target=/var/log <<-EOF
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y grub-efi linux-generic
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
