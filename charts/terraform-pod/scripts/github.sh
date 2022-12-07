#!/bin/bash

gh auth login -h github.com --with-token --with-token </home/terraform/.github/token
gh auth setup-git
git config --global user.name $USERNAME
git config --global user.email $USEREMAIL
git config --global --add safe.directory /home/terraform/workspace
