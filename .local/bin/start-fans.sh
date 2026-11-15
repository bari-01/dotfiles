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
GPU_HWMON="$(find_hwmon amdgpu)"

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
TEMP_HELPER="/tmp/fancontrol-demand"

# temperature curves (deg celsius)
CPU_MINTEMP=40
CPU_MAXTEMP=80

GPU_MINTEMP=45
GPU_MAXTEMP=70

# fan demand in milli celsius.

cat > "$TEMP_HELPER" <<EOF
#!/usr/bin/env bash
set -euo pipefail

cpu_temp=\$(<"$CPU_HWMON/temp1_input")
gpu_temp=\$(<"$GPU_HWMON/temp1_input")

[[ \$cpu_temp =~ ^[0-9]+$ && \$gpu_temp =~ ^[0-9]+$ ]]

cpu_min=$((CPU_MINTEMP * 1000))
cpu_max=$((CPU_MAXTEMP * 1000))

gpu_min=$((GPU_MINTEMP * 1000))
gpu_max=$((GPU_MAXTEMP * 1000))

if (( cpu_temp <= cpu_min )); then
    cpu_demand=0
elif (( cpu_temp >= cpu_max )); then
    cpu_demand=100
else
    cpu_demand=\$(( (cpu_temp - cpu_min) * 100 / (cpu_max - cpu_min) ))
fi

if (( gpu_temp <= gpu_min )); then
    gpu_demand=0
elif (( gpu_temp >= gpu_max )); then
    gpu_demand=100
else
    gpu_demand=\$(( (gpu_temp - gpu_min) * 100 / (gpu_max - gpu_min) ))
fi

if (( cpu_demand > gpu_demand )); then
    demand=\$cpu_demand
else
    demand=\$gpu_demand
fi

echo \$((demand * 1000))
EOF

chmod 744 "$TEMP_HELPER"

cat > "$CONFIG" <<EOF
INTERVAL=1

DEVNAME=$HP_NAME=hp $CPU_NAME=k10temp $GPU_NAME=amdgpu
DEVPATH=$HP_NAME=$HP_DEVPATH $CPU_NAME=$CPU_DEVPATH $GPU_NAME=$GPU_DEVPATH

FCTEMPS=$HP_NAME/pwm1=!$TEMP_HELPER $HP_NAME/pwm2=!$TEMP_HELPER
FCFANS=$HP_NAME/pwm1=$HP_NAME/fan1_input $HP_NAME/pwm2=$HP_NAME/fan2_input

MINTEMP=$HP_NAME/pwm1=0 $HP_NAME/pwm2=0
MAXTEMP=$HP_NAME/pwm1=100 $HP_NAME/pwm2=100

MINPWM=$HP_NAME/pwm1=60 $HP_NAME/pwm2=60
MAXPWM=$HP_NAME/pwm1=255 $HP_NAME/pwm2=255

MINSTART=$HP_NAME/pwm1=70 $HP_NAME/pwm2=70
MINSTOP=$HP_NAME/pwm1=60 $HP_NAME/pwm2=60
EOF

echo "Using:"
echo "  HP:  $HP_HWMON"
echo "  CPU: $CPU_HWMON"
echo "  GPU: $GPU_HWMON"

exec /usr/sbin/fancontrol "$CONFIG"

