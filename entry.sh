#!/bin/bash

echo "BStream - Indigo Technologies Broadcast Team (c) 2026"

echo "Starting dbus-daemon..."
mkdir -p /run/dbus
dbus-daemon \
    --session \
    --address=unix:path=/run/dbus/session \
    --fork

export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/dbus/session

echo "Cleaning stale Xvfb lock..."
rm -f /tmp/.X99-lock
rm -rf /tmp/.X11-unix/X99

echo "Initializing the display..."
Xvfb "$DISPLAY" -screen 0 1024x768x24 &
until xdpyinfo >/dev/null 2>&1; do
    sleep 0.1
done

export XDG_RUNTIME_DIR=/tmp/runtime
mkdir -p "$XDG_RUNTIME_DIR"
chmod 700 "$XDG_RUNTIME_DIR"

echo "Hiding the mouse cursor..."
unclutter -idle 0 &

echo "Starting PulseAudio server..."
pulseaudio \
    --daemonize=yes \
    --exit-idle-time=-1 \
    --log-target=stderr

until pactl info >/dev/null 2>&1; do
    sleep 0.1
done

echo "Building the sink..."
pactl load-module module-null-sink \
    sink_name=browser \
    sink_properties=device.description=Browser
pactl set-default-sink browser

echo "Starting the browser..."
chromium \
    --no-sandbox \
    --disable-gpu \
    --disable-dev-shm-usage \
    --disable-background-timer-throttling \
    --disable-backgrounding-occluded-windows \
    --disable-renderer-backgrounding \
    --autoplay-policy=no-user-gesture-required \
    --kiosk \
    --fullscreen \
    --app="$URL" &
CHROMIUM_PID=$!

echo "Starting the stream..."

ffmpeg \
    -thread_queue_size 512 \
    -f x11grab \
    -framerate 30 \
    -video_size 1024x768 \
    -i "$DISPLAY" \
    \
    -thread_queue_size 512 \
    -f pulse \
    -i browser.monitor \
    \
    -c:v libx264 \
    -preset veryfast \
    -tune zerolatency \
    -pix_fmt yuv420p \
    -g 60 \
    -keyint_min 60 \
    -sc_threshold 0 \
    \
    -c:a aac \
    -b:a 128k \
    -ar 48000 \
    -f flv \
    "rtmp://mediamtx:1935/live/$STREAM" &
FFMPEG_PID=$!

wait -n "$CHROMIUM_PID" "$FFMPEG_PID"