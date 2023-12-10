#!/bin/zsh

cd ~/esp/esp-idf-v5.1.2
git submodule update --init --recursive
./install.sh
. ./export.sh

cd ~/esp/esp-csi/examples/get-started/csi_recv_router
idf.py build
idf.py set-target esp32

# sed -i -e 's/myssid/Sueda_Lab_2.4/' sdkconfig
# sed -i -e 's/mypassword/suedalab2018/' sdkconfig
sed -i -e 's/myssid/aterm-5509a2-g/' sdkconfig
sed -i -e 's/mypassword/4e4cca1284bb2/' sdkconfig
sed -i -e 's/921600/115200/' sdkconfig
rm sdkconfig-e

PORT=`ls /dev/cu.*`
idf.py -p $PORT flash

TIME=$(date "+%Y-%m-%d_%H_%M_%S")
mkdir -p upload_data
OUTPUT_FILE="upload_data/$TIME.csv"
echo "timestamp,type,seq,mac,rssi,rate,sig_mode,mcs,bandwidth,smoothing,not_sounding,aggregation,stbc,fec_coding,sgi,noise_floor,ampdu_cnt,channel,secondary_channel,local_timestamp,ant,sig_len,rx_state,len,first_word,data" > $OUTPUT_FILE

start_sec=0
idf.py -p $PORT monitor | while read -r line; do  
  if [ ! -e $OUTPUT_FILE ]; then
    TIME=$(date "+%Y-%m-%d_%H_%M_%S")
    OUTPUT_FILE="upload_data/$TIME.csv"
    echo "timestamp,type,seq,mac,rssi,rate,sig_mode,mcs,bandwidth,smoothing,not_sounding,aggregation,stbc,fec_coding,sgi,noise_floor,ampdu_cnt,channel,secondary_channel,local_timestamp,ant,sig_len,rx_state,len,first_word,data" > $OUTPUT_FILE
  fi
  
  current_time=$(gdate +"%Y-%m-%d %H:%M:%S.%3N")
  if [[ $line == *"CSI_DATA"* ]]; then
    echo "$current_time,$line" >> $OUTPUT_FILE
    declare -i file_len=`cat $OUTPUT_FILE | wc -l`
    if [ "$file_len" -gt 280 ]; then
      curl -X 'POST' 'http://0.0.0.0:8000/predict' -H 'accept: application/json' -H 'Content-Type: multipart/form-data' -F 'file=@"'$OUTPUT_FILE'";type=text/plain' &
      #rm $OUTPUT_FILE
      break
    fi
  elif [[ $line == *"CSI RECV"* ]]; then  
    echo "start recv csi"
  fi
done