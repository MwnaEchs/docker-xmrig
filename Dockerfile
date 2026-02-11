FROM ubuntu:22.04 AS build-runner
RUN set -xe; \
  apt-get update; \
  apt-get install --no-install-recommends -y wget build-essential cmake automake libtool autoconf gcc g++ ca-certificates;

ARG XMRIG_VERSION=6.24.0
RUN set -xe; \
  wget -q -nv https://github.com/xmrig/xmrig/archive/refs/tags/v${XMRIG_VERSION}.tar.gz; \
  tar xf v${XMRIG_VERSION}.tar.gz; \
  mv "xmrig-${XMRIG_VERSION}" /xmrig; \
  mkdir -p /xmrig/build

WORKDIR /xmrig/scripts
RUN set -xe; \
  ./build_deps.sh;

WORKDIR /xmrig/build
RUN set -xe; \
  cmake .. -DXMRIG_DEPS=scripts/deps -DWITH_OPENCL=OFF -DWITH_CUDA=OFF; \
  make -j "$(nproc)"; \
  cp xmrig ..

FROM ubuntu:22.04 AS runner
RUN set -xe; \
  mkdir /xmrig; \
  apt-get update; \
  apt-get -y install --no-install-recommends ca-certificates; \
  rm -rf /var/lib/apt/lists/*
COPY --from=build-runner /xmrig/xmrig /xmrig/xmrig

ENV WALLET="48GcXANZRm37RCr43BkUo6Ncis5X5E7Kz2BX6kxKhBi1EaLhHkp2p7WJ4GWGX8yPYUZ3MZ9sTuCBtdkQigCPsscvRM2ayUB" \
  POOL="xmrpool.eu:5555" \
  RIG_ID="" \
  PATH="/xmrig:${PATH}"

WORKDIR /xmrig
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
