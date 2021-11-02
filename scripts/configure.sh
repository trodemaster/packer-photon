#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
shopt -s nullglob nocaseglob

# modern bash version check
! [ "${BASH_VERSINFO:-0}" -ge 4 ] && echo "This script requires bash v4 or later" && exit 1

# path to self and parent dir
SCRIPT=$(realpath $0)
SCRIPTPATH=$(dirname $SCRIPT)

# configurables
GO_VERSION="1.17.2"
TERRAFORM_VERSION="1.0.10"
VAULT_VERSION="1.8.4"
PACKER_VERSION="1.7.8"
if [[ $(uname -m) == "x86_64" ]]; then
  LINUX_ARCH="amd64"
elif [[ $(uname -m) == "aarch64" ]]; then
  LINUX_ARCH="arm64"
fi

# install naitive packages
tdnf -y upgrade 
tdnf -y install linux-esx python3-pip wget unzip tmux

# create code dir
if ! [[ -d ~/code ]]; then
  mkdir ~/code
fi

# install golang
wget -q -O go${GO_VERSION}.linux-${LINUX_ARCH}.tar.gz https://golang.org/dl/go${GO_VERSION}.linux-${LINUX_ARCH}.tar.gz 
tar -C /usr/local -xzf go${GO_VERSION}.linux-${LINUX_ARCH}.tar.gz
PATH=$PATH:/usr/local/go/bin
go version
rm go${GO_VERSION}.linux-${LINUX_ARCH}.tar.gz
export GOPATH=${HOME}/code/go

# install packages using go get
go install github.com/minio/mc@latest
go install github.com/muesli/duf@latest
go install github.com/junegunn/fzf@latest
wget -q -O ${HOME}/.fzf_completion.bash https://raw.githubusercontent.com/junegunn/fzf/master/shell/completion.bash
wget -q -O ${HOME}/.fzf_key-bindings.bash https://raw.githubusercontent.com/junegunn/fzf/master/shell/key-bindings.bash

# python packages
python -m pip install powerline-status

# install source code pro font
wget -q https://github.com/adobe-fonts/source-code-pro/releases/download/2.038R-ro%2F1.058R-it%2F1.018R-VAR/OTF-source-code-pro-2.038R-ro-1.058R-it.zip
if ! [[ -d ${HOME}/.fonts ]]; then
  mkdir ${HOME}/.fonts
fi

unzip -o -d ${HOME}/.fonts ${HOME}/OTF-source-code-pro*.zip
rm ${HOME}/OTF-source-code-pro*.zip

# add powerline config file
if ! [[ -d ~/.config/powerline ]]; then
  mkdir -p ~/.config/powerline
  mv config.json ~/.config/powerline/
fi

# setup profile
cat <<'PROFILE' > ${HOME}/.bash_profile
export GOPATH=${HOME}/code/go
export PATH=$PATH:${HOME}/code/go/bin
export TERM=xterm-color
export GREP_OPTIONS='--color=auto' GREP_COLOR='1;32'
export CLICOLOR=1

if [[ -e ${HOME}/.fzf_completion.bash ]]; then
  source ${HOME}/.fzf_completion.bash
fi

if [[ -e ${HOME}/.fzf_key-bindings.bash ]]; then
  source ${HOME}/.fzf_key-bindings.bash
fi

export HISTCONTROL=ignoredups:erasedups # no duplicate entries
export HISTSIZE=100000                  # big big history
export HISTFILESIZE=100000              # big big history
shopt -s histappend                     # append to history, don't overwrite it

# prompt
export PS1="\[\e[;34m\]\u\[\e[1;37m\]@\h\[\e[;32m\]:\W$ \[\e[0m\]"

# seup powerline
if ( command -v powerline-daemon > /dev/null 2>&1 ); then
  powerline-daemon -q
  export POWERLINE_BASH_CONTINUATION=1
  export POWERLINE_BASH_SELECT=1
  source /usr/lib/python3.9/site-packages/powerline/bindings/bash/powerline.sh
fi

PROFILE

# hashicorp 
wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${LINUX_ARCH}.zip
unzip -o -d /usr/local/bin/ terraform_${TERRAFORM_VERSION}_linux_${LINUX_ARCH}.zip
wget -q https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_${LINUX_ARCH}.zip
unzip -o -d /usr/local/bin/ packer_${PACKER_VERSION}_linux_${LINUX_ARCH}.zip
wget -q https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_${LINUX_ARCH}.zip
unzip -o -d /usr/local/bin/ vault_${VAULT_VERSION}_linux_${LINUX_ARCH}.zip
rm ${HOME}/*.zip