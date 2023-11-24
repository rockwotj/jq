FROM ghcr.io/webassembly/wasi-sdk:latest

ENV DEBIAN_FRONTEND=noninteractive \
    DEBCONF_NONINTERACTIVE_SEEN=true \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8

RUN apt-get update \
 && apt-get install -y \
      build-essential \
      autoconf \
      libtool \
      git \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . /app

ENV CFLAGS="-O2 -D_WASI_EMULATED_SIGNAL $CFLAGS" \
    LDFLAGS="$LDFLAGS -lwasi-emulated-signal"
RUN env && autoreconf -i \
 && ./configure \
      --host=wasm32-wasi \
      --disable-docs \
      --disable-valgrind \
      --disable-maintainer-mode \
      --with-oniguruma=builtin \
      --prefix=/usr/local \
 && make -j$(nproc) \
 && make install-libLTLIBRARIES install-includeHEADERS \
 && (cd modules/oniguruma/src && make install-libLTLIBRARIES install-includeHEADERS)
