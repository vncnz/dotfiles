#!/bin/bash

trap "trap - SIGTERM; active=0" SIGINT SIGTERM EXIT
active=1

while [ $active -ne 0 ]; do
	while playerctl status -a | grep Playing -qi && ! playerctl status | grep -qi "Playing"; do
		playerctld shift;
	done

	sleep 1 &
	wait $!
done

pkill -P $$