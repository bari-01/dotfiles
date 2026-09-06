#!/usr/bin/env bash
set -euo pipefail

find_hwmon() {
    local target="$1"

    for hw in /sys/class/hwmon/hwmon*; do
        [[ -f "$hw/name" ]] || continue

        if [[ "$(cat "$hw/name")" == "$target" ]]; then
            echo "$hw"
            return 0
        fi
    done

    return 1
}

HP_HWMON="$(find_hwmon hp)"
CPU_HWMON="$(find_hwmon k10temp)"

HP_NAME="$(basename "$HP_HWMON")"
CPU_NAME="$(basename "$CPU_HWMON")"
HP_DEVPATH=$(readlink -f "$HP_HWMON/device")
HP_DEVPATH=${HP_DEVPATH#/sys/}
CPU_DEVPATH=$(readlink -f "$CPU_HWMON/device")
CPU_DEVPATH=${CPU_DEVPATH#/sys/}
CONFIG="/run/fancontrol.dynamic"

#DEVPATH=$HP_NAME=devices/platform/hp-wmi $CPU_NAME=devices/pci0000:00/0000:00:18.3
cat > "$CONFIG" <<EOF
INTERVAL=5

DEVNAME=$HP_NAME=hp $CPU_NAME=k10temp
DEVPATH=$HP_NAME=$HP_DEVPATH $CPU_NAME=$CPU_DEVPATH

FCTEMPS=$HP_NAME/pwm1=$CPU_NAME/temp1_input
FCFANS=$HP_NAME/pwm1=$HP_NAME/fan1_input

MINTEMP=$HP_NAME/pwm1=55
MAXTEMP=$HP_NAME/pwm1=80
MINSTART=$HP_NAME/pwm1=100
MINSTOP=$HP_NAME/pwm1=60
EOF

echo "Using:"
echo "  HP:  $HP_HWMON"
echo "  CPU: $CPU_HWMON"

exec /usr/sbin/fancontrol "$CONFIG"
#exec /usr/sbin/fancontrol <(
#cat <<EOF
#INTERVAL=5
#
#DEVPATH=$HP_NAME=devices/platform/hp-wmi $CPU_NAME=devices/pci0000:00/0000:00:18.3
#DEVNAME=$HP_NAME=hp $CPU_NAME=k10temp
#
#FCTEMPS=$HP_NAME/pwm1=$CPU_NAME/temp1_input
#FCFANS=$HP_NAME/pwm1=$HP_NAME/fan1_input
#
#MINTEMP=$HP_NAME/pwm1=55
#MAXTEMP=$HP_NAME/pwm1=80
#MINSTART=$HP_NAME/pwm1=100
#MINSTOP=$HP_NAME/pwm1=60
#EOF
#)
