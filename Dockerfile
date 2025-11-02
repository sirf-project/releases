# syntax=docker/dockerfile:1.19
FROM ubuntu-base AS base

COPY plymouth/* /usr/share/plymouth/themes/sirf
COPY overrides /usr/share/glib-2.0/schemas/99_sirf.gschema.override

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    --mount=type=tmpfs,target=/var/log \
<<-EOF
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y perl ubuntu-minimal ubuntu-standard grub-efi plymouth-theme-spinner linux-headers-generic linux-image-generic
    update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth /usr/share/plymouth/themes/sirf/sirf.plymouth 200
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends snapd xdelta3 flatpak
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    apt-get clean
    deluser --remove-home ubuntu
EOF

FROM scratch

COPY --from=base / /
ENTRYPOINT ["/sbin/init"]
