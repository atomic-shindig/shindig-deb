FROM debian:trixie-slim AS builder
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
    curl \
    git \
    meson \
    ninja-build \
    pkg-config \
    gcc \
    dpkg-dev \
    scdoc \
    libsystemd-dev \
    dbus \
    ca-certificates

ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | \
    sh -s -- -y --profile minimal --default-toolchain stable

WORKDIR /build

RUN git clone --depth 1 \
    https://codeberg.org/HastD/brew-proxy.git /tmp/brew-proxy

RUN BREW_PROXY_VERSION="$(git -C /tmp/brew-proxy describe --tags --always)" && \
    echo "Building brew-proxy ${BREW_PROXY_VERSION}" && \
    mkdir -p /pkg/DEBIAN && \
    printf '%s\n' \
"Package: brew-proxy-git" \
"Version: 0${BREW_PROXY_VERSION}" \
"Section: admin" \
"Priority: optional" \
"Architecture: $(dpkg --print-architecture)" \
"Maintainer: JumpyVi <jumpyvi@outlook.com>" \
"Depends: dbus, libsystemd0" \
"Description: DBus-activated service for securely managing a shared Homebrew install (git version)" \
    > /pkg/DEBIAN/control

RUN meson setup /tmp/brew-proxy/build /tmp/brew-proxy \
    --buildtype=release \
    --prefix=/usr \
    -Dsysconfdir=/etc \
    -Dselinux=disabled && \
    ninja -C /tmp/brew-proxy/build && \
    DESTDIR=/pkg ninja -C /tmp/brew-proxy/build install

RUN mkdir -p /out && \
    dpkg-deb --build /pkg /out/brew-proxy-git_$(dpkg --print-architecture).deb

FROM scratch AS export
COPY --from=builder /out .