# syntax=docker/dockerfile:1.19
FROM ubuntu-base AS base

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    --mount=type=tmpfs,target=/var/log \
<<-EOF
    apt-get update
    apt-get install --no-install-recommends -y debconf-utils perl
EOF

RUN <<-EOF
debconf-set-selections <<DEBCONF
keyboard-configuration console-setup/ask_detect boolean false
console-setup console-setup/charmap47 select UTF-8
console-setup console-setup/codeset47 select Guess optimal character set
console-setup/codesetcode string guess
keyboard-configuration console-setup/detect detect-keyboard
keyboard-configuration console-setup/detected note
console-setup console-setup/fontface47 select Fixed
console-setup/fontsize string 8x16
console-setup console-setup/fontsize-fb47 select 8x16
console-setup console-setup/fontsize-text47 select 8x16
console-setup console-setup/store_defaults_in_debconf_db boolean true
DEBCONF
EOF

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    --mount=type=tmpfs,target=/var/log \
<<-EOF
    apt-get update
    apt-get install -y ubuntu-minimal
    rm -rf /var/lib/apt/lists/* /var/log/{alternatives.log,apt/{history.log,term.log},dpkg.log}
    deluser --remove-home ubuntu
EOF

FROM scratch AS apt

ENTRYPOINT ["/sbin/init"]
COPY --link --from=base / /

FROM apt AS flatpak

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    --mount=type=tmpfs,target=/var/log \
<<-EOF
    apt-get update
    apt-get install -y flatpak
    rm -rf /var/lib/apt/lists/* /var/log/{alternatives.log,apt/{history.log,term.log},dpkg.log}
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
EOF

FROM apt AS snap

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    --mount=type=tmpfs,target=/var/log \
<<-EOF
    apt-get update
    apt-get install -y snapd xdelta3
    rm -rf /var/lib/apt/lists/* /var/log/{alternatives.log,apt/{history.log,term.log},dpkg.log}
EOF

FROM apt AS all

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    --mount=type=tmpfs,target=/var/log \
<<-EOF
    apt-get update
    apt-get install -y snapd xdelta3 flatpak
    rm -rf /var/lib/apt/lists/* /var/log/{alternatives.log,apt/{history.log,term.log},dpkg.log}
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
EOF
