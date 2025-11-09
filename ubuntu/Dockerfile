# syntax=docker/dockerfile:1.19
FROM ubuntu-base AS base

# Delete the default ubuntu user to avoid conflicts
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    --mount=type=tmpfs,target=/var/log <<-EOF
    apt-get update
    apt-get dist-upgrade -y
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends perl
    deluser --remove-home ubuntu
    apt-get purge -y --auto-remove perl
    apt-get clean
EOF

# Copy Plymouth theme and GSettings overrides
RUN mkdir -p /usr/share/plymouth/themes/sirf
COPY --from=plymouth . /usr/share/plymouth/themes/sirf
COPY --from=overrides . /usr/share/glib-2.0/schemas

# Install Ubuntu Minimal with Generic Kernel
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    --mount=type=tmpfs,target=/var/log <<-EOF
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y ubuntu-minimal ubuntu-standard grub-efi plymouth-theme-spinner linux-generic
    update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth /usr/share/plymouth/themes/sirf/sirf.plymouth 200
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
