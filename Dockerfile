FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Tehran
ENV TERM=xterm-256color
ENV HOME=/root

# Base packages + X-UI dependencies
RUN apt-get update && apt-get install -y \
    curl wget git vim nano htop \
    python3 python3-pip \
    php php-cli \
    build-essential \
    unzip zip \
    sudo tzdata ca-certificates \
    openssh-server \
    socat \
    netcat \
    net-tools \
    tini \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Node.js 20
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install wetty
RUN npm install -g wetty

# Install X-UI
RUN cd /root && \
    curl -fsSL https://github.com/alireza0/x-ui/archive/refs/tags/v3.0.2.tar.gz -o x-ui.tar.gz && \
    tar -xzf x-ui.tar.gz && \
    mv x-ui-3.0.2 x-ui && \
    cd x-ui && \
    chmod +x x-ui.sh && \
    ./x-ui.sh install && \
    cd /root && rm -f x-ui.tar.gz

# Setup root user
RUN echo 'root:root123' | chpasswd \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Setup bashrc
RUN echo 'export PS1="\[\e[1;31m\][\u@vps \W]\$\[\e[0m\] "' >> /root/.bashrc \
    && echo 'alias ll="ls -la"' >> /root/.bashrc \
    && echo 'alias cls="clear"' >> /root/.bashrc \
    && echo 'alias xui="x-ui"' >> /root/.bashrc \
    && echo 'echo ""' >> /root/.bashrc \
    && echo 'echo "  ╔══════════════════════════════════════╗"' >> /root/.bashrc \
    && echo 'echo "  ║   Arvin VPS + X-UI Panel 🚀          ║"' >> /root/.bashrc \
    && echo 'echo "  ║   Panel: http://localhost:54321      ║"' >> /root/.bashrc \
    && echo 'echo "  ║   Wetty: http://localhost:3000       ║"' >> /root/.bashrc \
    && echo 'echo "  ╚══════════════════════════════════════╝"' >> /root/.bashrc \
    && echo 'echo ""' >> /root/.bashrc

# Create folders
RUN mkdir -p /root/main/arvin

WORKDIR /root/main/arvin

# Copy startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 3000 54321 443 80 2096

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/start.sh"]
