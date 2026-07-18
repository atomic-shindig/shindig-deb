FROM debian:trixie-slim AS builder
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
    curl \
    git \
    patch \
    zstd \
    dpkg-dev \
    ca-certificates

WORKDIR /build

RUN git clone --depth 1 https://github.com/ublue-os/brew.git /build/ublue-brew && \
    git clone --depth 1 https://github.com/homebrew/install.git /build/homebrew

RUN curl -fsSL \
    https://github.com/secureblue/homebrew/raw/f52ad9f26510667e467f17c2f330da68a870e592/homebrew-install.patch \
    -o /build/install.patch

RUN patch /build/homebrew/install.sh /build/install.patch

RUN HOMEBREW_VERSION="$(git -C /build/homebrew describe --tags --always 2>/dev/null || echo unknown)" && \
    echo "Building homebrew ${HOMEBREW_VERSION}" && \
    echo "${HOMEBREW_VERSION}" > /build/homebrew_version.txt

RUN mkdir -p /home/linuxbrew && \
    cd /home/linuxbrew && \
    env --ignore-environment \
      "PATH=/usr/bin:/bin:/usr/sbin:/sbin" \
      "HOME=/home/linuxbrew" \
      "NONINTERACTIVE=1" \
      /usr/bin/bash /build/homebrew/install.sh

RUN mkdir -p /build/pkgroot/home/linuxbrew && \
    mv /home/linuxbrew/.linuxbrew /build/pkgroot/home/linuxbrew/

RUN mkdir -p /pkg/DEBIAN /pkg/usr/share && \
    cp -a /build/ublue-brew/system_files/. /pkg/ 2>/dev/null || true && \
    tar --zstd -cf /pkg/usr/share/homebrew.tar.zst \
      -C /build/pkgroot home/linuxbrew/.linuxbrew

RUN HOMEBREW_VERSION="$(cat /build/homebrew_version.txt)" && \
    printf '%s\n' \
"Package: homebrew" \
"Version: 0${HOMEBREW_VERSION#v}" \
"Section: admin" \
"Priority: optional" \
"Architecture: $(dpkg --print-architecture)" \
"Maintainer: JumpyVi <jumpyvi@outlook.com>" \
"Depends: git, curl, zstd" \
"Recommends: brew-proxy" \
"Provides: brew, linuxbrew" \
"Conflicts: brew, linuxbrew" \
"Description: The Missing Package Manager for macOS (or Linux)" \
    > /pkg/DEBIAN/control

RUN printf '%s\n' \
"#!/bin/sh" \
"set -e" \
'echo "==> Adding Homebrew profile to global bashrc..."' \
'echo "source /etc/profile.d/brew.sh" >> /etc/bash.bashrc' \
"exit 0" \
    > /pkg/DEBIAN/postinst && \
    chmod 755 /pkg/DEBIAN/postinst

RUN mkdir -p /out && \
    dpkg-deb --build /pkg /out/homebrew_$(dpkg --print-architecture).deb

FROM scratch AS export
COPY --from=builder /out .