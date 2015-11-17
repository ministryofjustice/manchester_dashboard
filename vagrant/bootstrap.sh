#!/bin/bash

sudo locale-gen en_GB.UTF-8

sudo apt-get update
sudo apt-get -y upgrade

curl --silent --location https://deb.nodesource.com/setup_0.12 | sudo bash -

sudo apt-get -y install ruby-dev build-essential zlib1g-dev nodejs

sed -i '$a\
\
export RELEASE_STAGE="local"\
echo -e "\\033[0;31m======================================================\\033[0m"\
echo -e "\\n\\033[0;31mMake sure API is available at http://localhost:8001 on host\\033[0m"\
echo -e "\\n\\033[0;31mThen run: dashing start\\033[0m\\n"\
echo -e "\\033[0;31m======================================================\\033[0m"\
cd /dashboard
' .bashrc

echo "Installing dashing dependencies"
sudo gem install bundler

cd /dashboard

bundle install
