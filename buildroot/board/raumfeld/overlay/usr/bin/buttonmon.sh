#!/bin/sh

set -eu

# Minimal gpio-keys monitor without extra packages.
# Prints button press/release events to stdout (serial console if run there).

find_gpio_keys_event() {
	# Fast path: sysfs lookup by event device name.
	for namefile in /sys/class/input/event*/device/name; do
		[ -r "$namefile" ] || continue
		name=$(cat "$namefile" 2>/dev/null || true)
		case "$name" in
			*gpio-keys*|*gpio_keys*|*gpio*keys*)
				event=$(basename "$(dirname "$namefile")")
				echo "/dev/input/$event"
				return 0
				;;
		esac
	done

	# Fallback: parse /proc (works even if sysfs paths differ).
	[ -r /proc/bus/input/devices ] || return 1
	name=""
	handlers=""
	while IFS= read -r line; do
		case "$line" in
			N:\ Name=*)
				name=${line#N: Name=\"}
				name=${name%\"}
				;;
			H:\ Handlers=*)
				handlers=${line#H: Handlers=}
				;;
			"")
				if printf '%s' "$name" | grep -qiE 'gpio[-_ ]keys'; then
					for h in $handlers; do
						case "$h" in
							event*)
								echo "/dev/input/$h"
								return 0
								;;
						esac
					done
				fi
				name=""
				handlers=""
				;;
		esac
	done < /proc/bus/input/devices

	# Catch last block (if file doesn't end with blank line)
	if printf '%s' "$name" | grep -qiE 'gpio[-_ ]keys'; then
		for h in $handlers; do
			case "$h" in
				event*)
					echo "/dev/input/$h"
					return 0
					;;
			esac
		done
	fi

	return 1
}

key_name() {
	case "$1" in
		2) echo "KEY_1";;
		3) echo "KEY_2";;
		4) echo "KEY_3";;
		5) echo "KEY_4";;
		61) echo "KEY_F3";;
		114) echo "KEY_VOLUMEDOWN";;
		115) echo "KEY_VOLUMEUP";;
		116) echo "KEY_POWER";;
		141) echo "KEY_SETUP";;
		*) echo "KEY_$1";;
	esac
}

action_name() {
	case "$1" in
		0) echo "RELEASE";;
		1) echo "PRESS";;
		2) echo "REPEAT";;
		*) echo "VALUE_$1";;
	esac
}

event_size=16
case "$(uname -m 2>/dev/null || true)" in
	aarch64*) event_size=24;;
	*) event_size=16;;
 esac

printf '%s\n' "buttonmon: waiting for gpio-keys input device..." >&2

if [ ! -d /dev/input ]; then
	printf '%s\n' "buttonmon: /dev/input is missing; is devtmpfs mounted?" >&2
	printf '%s\n' "buttonmon: hint: try 'mount | grep devtmpfs'" >&2
fi

if [ "${1:-}" = "--list" ]; then
	printf '%s\n' "buttonmon: available input devices:" >&2
	if [ -r /proc/bus/input/devices ]; then
		cat /proc/bus/input/devices
	else
		printf '%s\n' "(no /proc/bus/input/devices)" >&2
	fi
	exit 0
fi

if [ "${1:-}" != "" ]; then
	dev="$1"
	if [ ! -e "$dev" ]; then
		printf '%s\n' "buttonmon: device '$dev' does not exist" >&2
		exit 1
	fi
else
	# Default to event0 (your current system has gpio-keys on event0).
	# If it doesn't exist, fall back to auto-detection.
	dev="/dev/input/event0"
	if [ ! -e "$dev" ]; then
		dev=""
		for _i in $(seq 1 50 2>/dev/null || echo "1 2 3 4 5 6 7 8 9 10"); do
			if dev=$(find_gpio_keys_event 2>/dev/null); then
				break
			fi
			sleep 1
		
		done
	fi
fi

if [ -z "$dev" ] || [ ! -e "$dev" ]; then
	printf '%s\n' "buttonmon: gpio-keys device not found (expected /dev/input/eventX with name gpio-keys)" >&2
	printf '%s\n' "buttonmon: hint: check /proc/bus/input/devices" >&2
	printf '%s\n' "buttonmon: you can also run: buttonmon.sh --list" >&2
	printf '%s\n' "buttonmon: or pass an explicit device: buttonmon.sh /dev/input/eventX" >&2
	exit 1
fi

name=$(cat "/sys/class/input/$(basename "$dev")/device/name" 2>/dev/null || echo "?")
printf '%s\n' "buttonmon: monitoring $dev (name: $name)" >&2
printf '%s\n' "buttonmon: press buttons; Ctrl+C to stop" >&2

# struct input_event (32-bit):
#   u32 tv_sec, u32 tv_usec, u16 type, u16 code, s32 value
# We ignore timestamps; only print EV_KEY (type=1)
while true; do
	dd if="$dev" bs="$event_size" count=1 2>/dev/null \
	| hexdump -v -e '1/4 "%u " 1/4 "%u " 1/2 "%u " 1/2 "%u " 1/4 "%d\n"' \
	| while read -r sec usec type code value; do
		# EV_SYN spam is type 0; ignore
		[ "${type:-}" = "1" ] || continue
		kn=$(key_name "${code:-0}")	act=$(action_name "${value:-0}")
		printf '%s\n' "buttonmon: $kn $act (code=${code:-?} value=${value:-?})"
	done

done
