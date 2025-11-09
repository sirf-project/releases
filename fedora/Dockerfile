# syntax=docker/dockerfile:1.19
FROM fedora-base AS base

# Copy Plymouth theme and GSettings overrides
RUN mkdir -p /usr/share/plymouth/themes/sirf
COPY --from=plymouth . /usr/share/plymouth/themes/sirf
COPY --from=overrides . /usr/share/glib-2.0/schemas

# Install Core and Standard packages
RUN --mount=type=cache,target=/var/cache/dnf,sharing=locked \
    --mount=type=tmpfs,target=/var/log <<-EOF
    dnf install -y @core @standard kernel kernel-headers plymouth-theme-spinner
    plymouth-set default-theme sirf -R
    dnf clean all
EOF

# Install Snap and Flatpak with Flathub remote
RUN --mount=type=cache,target=/var/cache/dnf,sharing=locked \
    --mount=type=tmpfs,target=/var/log <<-EOF
    dnf install -y snapd flatpak
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    dnf clean all
EOF

FROM scratch

COPY --link --from=base / /
ENTRYPOINT ["/sbin/init"]
