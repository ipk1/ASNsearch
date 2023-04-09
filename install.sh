#!/bin/bash

# Update system
sudo apt-get update
sudo apt-get upgrade -y

# Install required packages
sudo apt-get install -y jq curl python3 python3-pip golang

# Install Go packages
go get -u -v github.com/OWASP/Amass/v3/...
go get -u -v github.com/j3ssie/metabigor
go get -u -v github.com/XiphosResearch/xpasn

# Install Python packages
pip3 install --user requests

# Clone repositories
git clone https://github.com/woj-ciech/bgp_search.git ~/bgp_search
git clone https://github.com/yassineaboukir/Asnlookup.git ~/Asnlookup

# Set environment variables
echo 'export PATH=$PATH:~/go/bin' >> ~/.bashrc
source ~/.bashrc
