# syntax=docker/dockerfile:1.19
FROM fedora-base AS base

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

# Install Core and Standard packages
RUN --mount=type=cache,target=/var/cache/dnf,sharing=locked \
    --mount=type=tmpfs,target=/var/log <<-EOF
    dnf install -y @core @standard
EOF

# Install Kernel
RUN --mount=type=cache,target=/var/cache/dnf,sharing=locked \
    --mount=type=tmpfs,target=/var/log <<-EOF
    dnf install -y kernel kernel-headers
EOF

# Install Snap and Flatpak with Flathub remote
RUN --mount=type=cache,target=/var/cache/dnf,sharing=locked \
    --mount=type=tmpfs,target=/var/log <<-EOF
    dnf install -y flatpak PackageKit snapd
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    ln -s /var/lib/snapd/snap /snap
EOF

ENTRYPOINT ["/sbin/init"]
CMD ["/bin/bash", "-euxo", "pipefail"]
