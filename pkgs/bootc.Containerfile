FROM debian:sid-slim AS builder

ENV DEBIAN_FRONTEND=noninteractive
ENV CARGO_HOME=/tmp/rust
ENV RUSTUP_HOME=/tmp/rust

RUN apt-get update && \
    apt-get install -y \
    curl \
    make \
    build-essential \
    go-md2man \
    libzstd-dev \
    zstd \
    pkg-config \
    clang \
    llvm \
    libssl-dev \
    dracut \
    libostree-dev \
    ostree \
    dpkg-dev \
    ca-certificates

WORKDIR /build

RUN curl --proto '=https' --tlsv1.2 -sSf \
    https://sh.rustup.rs | sh -s -- --profile minimal -y

RUN BOOTC_VERSION="$(curl -sf https://api.github.com/repos/bootc-dev/bootc/releases/latest | \
grep '"tag_name"' | \
sed 's/.*"v\([^"]*\)".*/\1/' \
)" && \
    echo "Building bootc ${BOOTC_VERSION}" && \
    curl -L \
    "https://github.com/bootc-dev/bootc/releases/download/v${BOOTC_VERSION}/bootc-${BOOTC_VERSION}.tar.zstd" \
    -o /tmp/bootc.tar.zstd && \
    mkdir -p /tmp/bootc && \
    tar --zstd -xf /tmp/bootc.tar.zstd \
    -C /tmp/bootc \
    --strip-components=1 && \
    mkdir -p /pkg/DEBIAN && \
    printf '%s\n' \
    "Package: bootc" \
    "Version: ${BOOTC_VERSION}" \
    "Section: admin" \
    "Priority: optional" \
    "Architecture: $(dpkg --print-architecture)" \
    "Maintainer: JumpyVi <jumpyvi@outlook.com>" \
    "Depends: dracut, ostree" \
    "Description: bootc" \
    > /pkg/DEBIAN/control

RUN . /tmp/rust/env && \
    make -C /tmp/bootc \
    PREFIX=/usr \
    DESTDIR=/pkg \
    bin install-all

RUN mkdir -p /pkg/usr/lib/dracut/dracut.conf.d && \
    printf '%s\n' \
    'systemdsystemconfdir=/etc/systemd/system' \
    'systemdsystemunitdir=/usr/lib/systemd/system' \
    > /pkg/usr/lib/dracut/dracut.conf.d/30-bootc.conf

RUN mkdir -p /out && \
    dpkg-deb --build /pkg /out/bootc_$(dpkg --print-architecture).deb

FROM scratch AS export
COPY --from=builder /out /