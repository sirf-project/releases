# syntax=docker/dockerfile:1.19
FROM fedora-base AS base

# Install Core and Standard packages
RUN --mount=type=cache,target=/var/cache/dnf,sharing=locked \
    --mount=type=tmpfs,target=/var/log <<-EOF
    dnf upgrade -y
    dnf install -y @core kernel kernel-headers @standard
    dnf clean all
EOF

# Install Snap and Flatpak with Flathub remote
RUN --mount=type=cache,target=/var/cache/dnf,sharing=locked \
    --mount=type=tmpfs,target=/var/log <<-EOF
    dnf install -y flatpak PackageKit snapd
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    ln -s /var/lib/snapd/snap /snap
    dnf clean all
EOF

FROM scratch

COPY --link --from=base / /
ENTRYPOINT ["/sbin/init"]
