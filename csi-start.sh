#!/bin/zsh

cd ~/esp/esp-idf-v5.1.2
git submodule update --init --recursive
./install.sh
. ./export.sh

cd ~/esp/esp-csi/examples/get-started/csi_recv_router
idf.py build
idf.py set-target esp32

sed -i -e 's/myssid/Sueda_Lab_2.4/' sdkconfig
sed -i -e 's/mypassword/suedalab2018/' sdkconfig
# sed -i -e 's/myssid/aterm-5509a2-g/' sdkconfig
# sed -i -e 's/mypassword/4e4cca1284bb2/' sdkconfig
sed -i -e 's/921600/115200/' sdkconfig
rm sdkconfig-e

PORT=`ls /dev/cu.*`
idf.py -p $PORT flash

TIME=$(date "+%Y-%m-%d_%H_%M_%S")
data=()
idf.py -p $PORT monitor | while read -r line; do
  current_time=$(gdate +"%Y-%m-%d %H:%M:%S.%3N")
  if [[ $line == *"CSI_DATA"* ]]; then
    data+=("$current_time,$line")
    current_sec=$(date +%s)
    elapsed_time=$((current_sec - start_sec))
    if [ "$elapsed_time" -ge 5 ]; then
      echo "finish"
      echo $data[1]
      break
    fi
  elif [[ $line == *"CSI RECV"* ]]; then
    echo "start recv csi"
    start_sec=$(date +%s)
  fi
done