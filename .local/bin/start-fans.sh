#!/usr/bin/env bash
set -euo pipefail

#DEVPATH=$HP_NAME=devices/platform/hp-wmi $CPU_NAME=devices/pci0000:00/0000:00:18.3

#exec /usr/sbin/fancontrol "$CONFIG"
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

find_hwmon() {
    local hw
    for hw in /sys/class/hwmon/hwmon*; do
        [[ $(<"$hw/name") == "$1" ]] && { echo "$hw"; return 0; }
    done
    return 1
}

HP_HWMON=$(find_hwmon hp)
CPU_HWMON=$(find_hwmon k10temp)
GPU_HWMON=$(find_hwmon amdgpu)

HP_NAME="$(basename "$HP_HWMON")"
CPU_NAME="$(basename "$CPU_HWMON")"
GPU_NAME="$(basename "$GPU_HWMON")"

HP_DEVPATH=$(readlink -f "$HP_HWMON/device")
HP_DEVPATH=${HP_DEVPATH#/sys/}
CPU_DEVPATH=$(readlink -f "$CPU_HWMON/device")
CPU_DEVPATH=${CPU_DEVPATH#/sys/}
GPU_DEVPATH=$(readlink -f "$GPU_HWMON/device")
GPU_DEVPATH=${GPU_DEVPATH#/sys/}

CONFIG="/run/fancontrol.dynamic"
STATE_FILE="/run/fancontrol-latch"

INTERVAL=1
AVERAGE=3
CPU_ON=41 CPU_OFF=38 CPU_MIN=41 CPU_MAX=75
GPU_ON=46 GPU_OFF=43 GPU_MIN=46 GPU_MAX=65
SIGMOID_K=6
MINSTART=70 MINSTOP=60 MAX_PWM=255

export STATE_FILE SIGMOID_K
export CPU_TEMP_PATH="$CPU_HWMON/temp1_input" GPU_TEMP_PATH="$GPU_HWMON/temp1_input"
export CPU_ON CPU_OFF CPU_MIN CPU_MAX GPU_ON GPU_OFF GPU_MIN GPU_MAX

# /run is noexec
TEMP_HELPER="/tmp/fancontrol-demand"

rm CONFIG STATE_FILE TEMP_HELPER

cat > "$TEMP_HELPER" <<'HELPER'
#!/usr/bin/env bash
set -euo pipefail

cpu=$(<"$CPU_TEMP_PATH")
gpu=$(<"$GPU_TEMP_PATH")
on=$(cat "$STATE_FILE" 2>/dev/null || echo 0)

if (( on )); then
    (( cpu > CPU_OFF * 1000 || gpu > GPU_OFF * 1000 )) || on=0
elif (( cpu >= CPU_ON * 1000 || gpu >= GPU_ON * 1000 )); then
    on=1
fi
echo "$on" > "$STATE_FILE"
(( on )) || { echo 0; exit 0; }

# Logistic curve
awk -v c="$cpu" -v g="$gpu" -v k="$SIGMOID_K" \
    -v cl="$CPU_MIN" -v ch="$CPU_MAX" -v gl="$GPU_MIN" -v gh="$GPU_MAX" '
BEGIN {
    c = (c / 1000 - cl) / (ch - cl)
    g = (g / 1000 - gl) / (gh - gl)
    x = c > g ? c : g
    x = x < 0 ? 0 : x > 1 ? 1 : x
    lo = 1 / (1 + exp(k / 2)); hi = 1 / (1 + exp(-k / 2))
    y = (1 / (1 + exp(-k * (x - 0.5))) - lo) / (hi - lo)
    y = y * 1.1; if (y > 1) y = 1
    printf "%d\n", 1000 + y * 99000
}'
HELPER
chmod 744 "$TEMP_HELPER"

cat > "$CONFIG" <<EOF
INTERVAL=$INTERVAL
DEVNAME=$HP_NAME=hp $CPU_NAME=k10temp $GPU_NAME=amdgpu
DEVPATH=$HP_NAME=$HP_DEVPATH $CPU_NAME=$CPU_DEVPATH $GPU_NAME=$GPU_DEVPATH
FCTEMPS=$HP_NAME/pwm1=!$TEMP_HELPER $HP_NAME/pwm2=!$TEMP_HELPER
FCFANS=$HP_NAME/pwm1=$HP_NAME/fan1_input $HP_NAME/pwm2=$HP_NAME/fan2_input
MINTEMP=$HP_NAME/pwm1=0 $HP_NAME/pwm2=0
MAXTEMP=$HP_NAME/pwm1=100 $HP_NAME/pwm2=100
MINPWM=$HP_NAME/pwm1=0 $HP_NAME/pwm2=0
MAXPWM=$HP_NAME/pwm1=$MAX_PWM $HP_NAME/pwm2=$MAX_PWM
MINSTART=$HP_NAME/pwm1=$MINSTART $HP_NAME/pwm2=$MINSTART
MINSTOP=$HP_NAME/pwm1=$MINSTOP $HP_NAME/pwm2=$MINSTOP
AVERAGE=$HP_NAME/pwm1=$AVERAGE $HP_NAME/pwm2=$AVERAGE
EOF

echo "Using:"
echo "  HP:  $HP_HWMON"
echo "  CPU: $CPU_HWMON"
echo "  GPU: $GPU_HWMON"

exec /usr/sbin/fancontrol "$CONFIG"
