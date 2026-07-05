FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:99

# install packages n stuff
RUN apt-get update && apt-get install -y \
    ffmpeg \
    chromium \
    xvfb \
    dbus-x11 \
    pulseaudio \
    x11-utils \
    xauth \
    fonts-dejavu \
    fonts-liberation \
    fonts-noto \
    fonts-noto-cjk \
    fonts-noto-color-emoji \
    libgtk-3-0 \
    libgbm1 \
    libx11-xcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxrandr2 \
    libxrender1 \
    libxtst6 \
    libnss3 \
    libasound2 \
    libatk-bridge2.0-0 \
    libdrm2 \
    ca-certificates \
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/*

# copy entrypoint
COPY entry.sh /entry.sh
RUN chmod +x /entry.sh

# FLOOR IT!!
ENTRYPOINT ["/bin/bash", "entry.sh"]