#!/usr/bin/env bash

# Enable Power Nap for laptops (while on battery power) and desktops.
sudo pmset -a powernap 1
# Laptops/Power Adapter: [✓] Prevent computer from sleeping automatically when the display is off
# Desktops: [✓] Start up automatically after a power failure
sudo pmset -a autorestart 1
