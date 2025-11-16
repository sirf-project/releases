# syntax=docker/dockerfile:1.19
FROM debian-base AS base

# Update system
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    --mount=type=tmpfs,target=/var/log <<-EOF
    apt-get update
    apt-get dist-upgrade -y
    apt-get clean
EOF

# Copy Plymouth theme and GSettings overrides
RUN mkdir -p /usr/share/plymouth/themes/sirf
COPY --from=plymouth . /usr/share/plymouth/themes/sirf
COPY --from=overrides . /usr/share/glib-2.0/schemas

# Install Debian Standard with Generic Kernel
ARG PLYMOUTH_FONT
ARG PLYMOUTH_TITLE_FONT
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    --mount=type=tmpfs,target=/var/log <<-EOF
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y tasksel grub-efi plymouth-themes linux-image-$(dpkg --print-architecture)
    tasksel install standard
    sed -i "s/^Font=.*/Font=${PLYMOUTH_FONT}/" /usr/share/plymouth/themes/sirf/sirf.plymouth
    sed -i "s/^TitleFont=.*/TitleFont=${PLYMOUTH_TITLE_FONT}/" /usr/share/plymouth/themes/sirf/sirf.plymouth
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
