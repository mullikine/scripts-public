#!/bin/bash
export TTY

sudo chown -R shane ~/.cache/rply
/usr/local/bin/hy "$@"