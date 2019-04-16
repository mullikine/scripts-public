#!/bin/bash
export TTY
# shopt -s nullglob # use for 'for' loops but not for 'ls', 'grep'

# This fixes the internet connection
(
sudo /etc/init.d/wicd stop
sudo /etc/init.d/network-manager restart
sudo /etc/init.d/networking restart
) & disown

sudo /etc/init.d/mysql start
sudo /etc/init.d/apache2 start
sudo /etc/init.d/sphinxsearch start
