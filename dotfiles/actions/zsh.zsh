#!/usr/bin/env zsh

# This script initializes the zsh dotfiles setup.
#
# Arguments:
#   - $1: The file defining the zsh configuration directory path.

# This doesn't work if this script is sourced
. "$(dirname "$0")/../.env"

#######################################
# Arguments processing
#######################################

ZDOTDIR_FILE="${1:?}"

#######################################
# Loading configuration paths
#######################################

# The shell configuration paths need to be loaded manually, rather than by the
# shell itself. This is because the dotfiles are indeed not set up yet, as this
# very script is meant to do so.

. "$ZDOTDIR_FILE"

#######################################
# Creating symbolic links
#######################################

# zsh offers the possibility to change the default config path by setting the
# ZDOTDIR environment variable. However, such variable needs to be set
# BEFORE zsh is initialized, making the setup very convoluted without using the
# default path. Therefore, the default path of first file to be loaded
# ($HOME/.zshenv) has been turned to a symlink to the actual file in the zsh
# configuration directory.

ln -sf "${ZDOTDIR:?}/.zshenv" "$HOME/.zshenv"

#######################################
# Initializing $ZDOTDIR
#######################################

mkdir -p "${ZDOTDIR:?}/cache"

#######################################
# Installing antibody
#######################################

case "$DISTRO" in
    'arch')
        yay -S antibody-bin asdf-vm
        ;;

    'debian')
        sudo mr -d /opt/antibody -c /opt/.mrconfig install
        sudo mr -d /opt/asdf-vm -c /opt/.mrconfig install
        ;;
esac

#######################################
# Installing plugins
#######################################

cd "$ZDOTDIR/interactive/plugins" || exit
antibody bundle < lists/plugins-before-compinit.list \
    > plugins-before-compinit.zsh
antibody bundle < lists/plugins-after-compinit.list \
    > plugins-after-compinit.zsh
cd - &> /dev/null || exit

cd "$ZDOTDIR/theme" || exit
antibody bundle < themes.list > themes.zsh
cd - &> /dev/null || exit

#######################################
# Initializing cache
#######################################

env TF_SHELL='zsh' thefuck --alias > "${ZDOTDIR:?}/cache/thefuck"
fasd --init zsh-hook zsh-ccomp zsh-ccomp-install zsh-wcomp zsh-wcomp-install \
    > "${ZDOTDIR:?}/cache/fasd"

touch "${ZDOTDIR:?}/cache/zygal"
source "$ZDOTDIR/interactive/theme/dotfiles/zygal-conf.zsh"
zsh -c zygal-static > "${ZDOTDIR:?}/cache/zygal"
