# syntax=docker/dockerfile:1.14
FROM ubuntu-base AS init-stage

RUN <<-EOT
    apt-get update
    apt-get install --no-install-recommends -y debconf-utils perl
EOT

RUN <<-EOT
    echo "keyboard-configuration console-setup/ask_detect boolean false" | debconf-set-selections
    echo "console-setup console-setup/charmap47 select UTF-8" | debconf-set-selections
    echo "console-setup console-setup/codeset47 select Guess optimal character set" | debconf-set-selections
    echo "console-setup/codesetcode string guess" | debconf-set-selections
    echo "keyboard-configuration console-setup/detect detect-keyboard" | debconf-set-selections
    echo "keyboard-configuration console-setup/detected note" | debconf-set-selections
    echo "console-setup console-setup/fontface47 select Fixed" | debconf-set-selections
    echo "console-setup/fontsize string 8x16" | debconf-set-selections
    echo "console-setup console-setup/fontsize-fb47 select 8x16" | debconf-set-selections
    echo "console-setup console-setup/fontsize-text47 select 8x16" | debconf-set-selections
    echo "console-setup console-setup/store_defaults_in_debconf_db boolean true" | debconf-set-selections
EOT

RUN <<-EOT
    apt-get install -y ubuntu-minimal
    rm -rf /var/lib/apt/lists/* /var/log/{alternatives.log,apt/{history.log,term.log},dpkg.log}
    deluser --remove-home ubuntu
EOT

FROM scratch AS interim-stage

ENTRYPOINT ["/sbin/init" ]
COPY --link --from=init-stage / /

FROM interim-stage AS apt

FROM interim-stage AS flatpak

RUN <<-EOT
    apt-get update
    apt-get install -y flatpak
    rm -rf /var/lib/apt/lists/* /var/log/{alternatives.log,apt/{history.log,term.log},dpkg.log}
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
EOT

FROM interim-stage AS snap

RUN <<-EOT
    apt-get update
    apt-get install -y snapd xdelta3
    rm -rf /var/lib/apt/lists/* /var/log/{alternatives.log,apt/{history.log,term.log},dpkg.log}
EOT

FROM interim-stage AS all

RUN <<-EOT
    apt-get update
    apt-get install -y snapd xdelta3 flatpak
    rm -rf /var/lib/apt/lists/* /var/log/{alternatives.log,apt/{history.log,term.log},dpkg.log}
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
EOT
