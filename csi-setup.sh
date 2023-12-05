#!/bin/zsh


brew install cmake

mkdir ~/esp
cd ~/esp
git clone -b v5.1.2 --recursive https://github.com/espressif/esp-idf.git esp-idf-v5.1.2
git clone https://github.com/espressif/esp-csi.git