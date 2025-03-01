#!/usr/bin/env sh
FIFO_DIR="/audio"
CONFIG_FILE="/etc/snapserver.conf"

echo "[stream]" > $CONFIG_FILE

for fifo in ${FIFO_DIR}/*.fifo; do
	[ -e "$fifo" ] || continue
	NAME=$(basename "$fifo" .fifo)
	echo "stream = pipe://$fifo?name=$NAME&codec=opus" >> $CONFIG_FILE
done

exec /usr/bin/snapserver -c $CONFIG_FILE
