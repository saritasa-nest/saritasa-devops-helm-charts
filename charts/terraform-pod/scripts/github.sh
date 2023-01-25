#!/bin/bash

if [[ -f /home/terraform/git-crypt-key ]]; then
    echo "You don't have git-crypt-key - pls be careful"
fi

gh auth login -h github.com --with-token --with-token </home/terraform/.github/token
gh auth setup-git
git config --global user.name $USERNAME
git config --global user.email $USEREMAIL
git config --global --add safe.directory /home/terraform/workspace
echo "Git Configuration & Auth is done"
