#!/bin/bash

# Uninstall the virtual microphone.

pactl unload-module module-pipe-source
rm /home/$USER/.config/pulse/client.conf
