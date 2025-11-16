# syntax=docker/dockerfile:1.19
FROM debian-base AS base

# Enable Non Free Repos and Update system
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    --mount=type=tmpfs,target=/var/log <<-EOF
    sed -i 's/main$/main contrib non-free non-free-firmware/' /etc/apt/sources.list.d/debian.sources
    apt-get update
    apt-get dist-upgrade -y
    apt-get clean
EOF

# Install Debian Standard with Generic Kernel
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    --mount=type=tmpfs,target=/var/log <<-EOF
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y tasksel grub-efi linux-base linux-perf linux-image-generic linux-headers-generic firmware-linux-free firmware-linux-nonfree
    tasksel install standard
    apt-get clean
EOF

# Install Snap and Flatpak with Flathub remote
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    --mount=type=tmpfs,target=/var/log <<-EOF
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends flatpak packagekit-tools snapd xdelta3
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    apt-get clean
EOF

FROM scratch

COPY --link --from=base / /
ENTRYPOINT ["/sbin/init"]
