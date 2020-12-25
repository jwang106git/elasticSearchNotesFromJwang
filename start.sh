nohup bash /usr/local/bin/elasticsearch  -Epath.data=data1 -Epath.logs=log1 &


sleep 3
nohup bash /usr/local/bin/elasticsearch  -Epath.data=data2 -Epath.logs=log2 &


sleep 3
nohup bash /usr/local/bin/elasticsearch  -Epath.data=data3 -Epath.logs=log3 &
