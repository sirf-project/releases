# syntax=docker/dockerfile:1.19
FROM fedora-base AS base

# Copy Plymouth theme and GSettings overrides
RUN mkdir -p /usr/share/plymouth/themes/sirf
COPY --from=plymouth . /usr/share/plymouth/themes/sirf
COPY --from=overrides . /usr/share/glib-2.0/schemas

# Install Core and Standard packages
ARG PLYMOUTH_FONT
ARG PLYMOUTH_TITLE_FONT
RUN --mount=type=cache,target=/var/cache/dnf,sharing=locked \
    --mount=type=tmpfs,target=/var/log <<-EOF
    dnf install -y @core @hardware-support kernel kernel-headers plymouth-theme-spinner @standard
    sed -i "s/^Font=.*/Font=${PLYMOUTH_FONT}/" /usr/share/plymouth/themes/sirf/sirf.plymouth
    sed -i "s/^TitleFont=.*/TitleFont=${PLYMOUTH_TITLE_FONT}/" /usr/share/plymouth/themes/sirf/sirf.plymouth
    plymouth-set-default-theme sirf
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
