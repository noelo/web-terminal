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
PATH="/home/user/node_modules/opencode-linux-x64/bin/:$PATH"
export PATH

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

unset rc

export EDITOR=vim

function help_message() {
  echo "Installed tools:"
  cat .installed_tools.txt
  echo ""
}

alias help=help_message

echo 'Welcome to the OpenShift Web Terminal Custom Image with OpenCode: Type "help" for a list of installed CLI tools.'
