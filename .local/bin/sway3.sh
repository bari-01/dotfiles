set -eux

MODE="${1:-}"
TRAP="${2:-}"

case "$MODE" in
    vnc|sunshine|'') ;;
                  *) ;
esac
[ (-n "$MODE" && "$MODE" != "vnc" && $MODE != "sunshine") ||
     (-n "$TRAP" && "$TRAP" != "notrap") ] &&
     { echo "Usage: $0 {vnc|sunshine|''} {notrap}" >&2; exit 2 ; }

SWRUN="$(mktemp -d "/run/user/$(id -u)/sway-remote.XXXXXX")"

chmod 700 "$SWRUN"

SUNSHINE_PID=""
WAYVNC_PID=""
SWAY_PID=""
SWAYSOCK=""
WAYLAND_DISPLAY=""

cleanup() {
    #set +e
    [ -n "$SUNSHINE_PID" ] && kill "$SUNSHINE_PID" 2>/dev/null
    [ -n "$WAYVNC_PID" ] && kill "$WAYVNC_PID" 2>/dev/null
    [ -n "$SWAYSOCK" ] && swaymsg -s "$SWAYSOCK" exit 2>/dev/null
    [ -n "$SWAY_PID" ] && wait "$SWAY_PID" 2>/dev/null
    rm -rf "$SWRUN"
}

[ -n "$TRAP" ] && trap cleanup EXIT INT TERM

export XDG_RUNTIME_DIR="$SWRUN"
echo "Runtime: $XDG_RUNTIME_DIR"

WLR_BACKENDS=headless WLR_LIBINPUT_NO_DEVICES=1 sway & SWAY_PID=$!

while :; do
    SWAYSOCK="$(
        find "$XDG_RUNTIME_DIR" -maxdepth 1 -type s \
        -name 'sway-ipc.*.sock' -print -quit
    )"
    [ -n "$SWAYSOCK" ] && break
    [ ! [ kill -0 "$SWAY_PID" 2>/dev/null ]] && exit 1
    sleep 0.2
done

export SWAYSOCK

while :; do
    WAYLAND_DISPLAY="$(
        find "$XDG_RUNTIME_DIR" -maxdepth 1 -type s -name 'wayland-*' \
            -printf '%f\n' -quit
    )"
    [ -n "$WAYLAND_DISPLAY" ] && break
    [ ! [ kill -0 "$SWAY_PID" 2>/dev/null ]] && exit 1
    sleep 0.2
done

export WAYLAND_DISPLAY

OUTPUT="$(swaymsg -s "$SWAYSOCK" -t get_outputs -r | jq -r '.[0].name')"

echo "Output: $OUTPUT"
echo "WAYLAND_DISPLAY: $WAYLAND_DISPLAY"
echo "SWAYSOCK: $SWAYSOCK"

swaymsg -s "$SWAYSOCK" output "$OUTPUT" resolution 1920x1080

case "$MODE" in
    vnc|'')
        echo "Starting wayvnc on 0.0.0.0:5900"

        env \
            XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
            WAYLAND_DISPLAY="$WAYLAND_DISPLAY" \
            wayvnc 0.0.0.0 5900 &

        WAYVNC_PID=$!
        ;;
    sunshine|'')
        env \
            XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
            WAYLAND_DISPLAY="$WAYLAND_DISPLAY" \
            SWAYSOCK="$SWAYSOCK" \
            sunshine &

        SUNSHINE_PID=$!
esac

[ -n "$TRAP" ] && wait "$SWAY_PID"
