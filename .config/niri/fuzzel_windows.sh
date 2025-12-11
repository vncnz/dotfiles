#!/usr/bin/env bash

URGENT="${1:-0}"

if [ $URGENT = 0 ]; then
	# List all windows
	WINDOWS=$(niri msg --json windows)
elif [ $URGENT = 1 ]; then
	# Filter to only windows marked as urgent
	WINDOWS=$(niri msg --json windows | jq -r 'map(select(.is_urgent == true))')
fi

WINDOW_COUNT=$(jq 'length' <<<$WINDOWS)

case $WINDOW_COUNT in
	0)
		# No windows: exit.
		exit 0
		;;
	1)
		# One window: focus it rather than using a picker.
		niri msg action focus-window --id \
			$(jq -r ".[0].id" <<< $WINDOWS)
		;;
	*)
		# Multiple windows: display the picker.
		choice=$(
			jq -r 'map("\(.title // .app_id)\u0000icon\u001f\(.app_id)") | .[]' <<<$WINDOWS \
				| fuzzel -d --index
			)

		index=${choice%%:*}  # Strip to get numeric index
		id=$(jq -r ".[$index].id" <<<$WINDOWS)
		niri msg action focus-window --id "$id"
		;;
esac