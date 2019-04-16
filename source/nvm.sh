# This causes a lot of lag. Put it into .profile so I don't get lag.
# That might mean that it won't work at all though because it appears to
# only work when given a tty. NICE! It works in profile. Don't put this
# in zshrc or bashrc or it will lag.


# Disable this until I can find a way to stop tmux from using it
{
    # This is needed because "tmux new" runs a login shell by defaut. so
    # profile is sourced by dash and i get errors
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
export PATH=${PATH#/usr/bin:} # This does actually work. The : does not mess with it
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
} 1>/dev/null 2>/dev/null

# nvm use default

