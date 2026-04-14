# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH
PATH="/projects/node_modules/.bin:$PATH"
PATH="/home/user/node_modules/opencode-linux-x64/bin/:/home/user/node_modules/.bin:$PATH"
export PATH

[ -f $HOME/ssh-environment ] && source $HOME/ssh-environment

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
        for rc in ~/.bashrc.d/*; do
                if [ -f "$rc" ]; then
                        . "$rc"
                fi
        done
fi

# Start ssh-agent only if not already running
if [ -z "$SSH_AUTH_SOCK" ]; then
    eval "$(ssh-agent -s)"
    cat /etc/ssh/passphrase | ssh-add /etc/ssh/dwo_ssh_key
fi

# Check if .continue/preload file exists, if not copy config and create preload file
if [ ! -f "$HOME/.continue/preload" ]; then
    cp /home/user/continuedev/config-map/config.yaml /home/user/.continue/config.yaml 2>/dev/null
    touch "$HOME/.continue/preload" 2>/dev/null
fi

unset rc
export OPENSPEC_TELEMETRY=0
export EDITOR=vim