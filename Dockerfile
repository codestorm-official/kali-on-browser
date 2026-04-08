FROM kalilinux/kali-rolling

ENV PORT=7681
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates wget curl git python3 python3-pip tini fastfetch iproute2 sudo && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /root/workspace

RUN set -eux; \
    ARCH="$(uname -m)"; \
    case "$ARCH" in \
        x86_64|amd64)  ASSET="ttyd.x86_64" ;; \
        aarch64|arm64) ASSET="ttyd.aarch64" ;; \
        *) echo "Error: Unsupported architecture ($ARCH)"; exit 1 ;; \
    esac; \
    \
    URL="https://github.com/tsl0922/ttyd/releases/latest/download/${ASSET}"; \
    wget -qO /usr/local/bin/ttyd "$URL"; \
    \
    chmod +x /usr/local/bin/ttyd

RUN echo "cd /root/workspace" >> /root/.bashrc && \
    echo "fastfetch || true" >> /root/.bashrc

EXPOSE 7681

ENTRYPOINT ["/usr/bin/tini", "--"]

CMD ["/bin/bash", "-c", "/usr/local/bin/ttyd --writable --interface 0.0.0.0 -p ${PORT:-7681} -c ${USERNAME:-admin}:${PASSWORD:-admin} /bin/bash -l"]