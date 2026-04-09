#!/usr/bin/env bash
set -euo pipefail

APP="/opt/PreSonus/Studio One 6/Studio One"
USER_NAME="ony"
LOG_FILE="/tmp/studio-one.log"

is_running() {
  pgrep -u "$USER_NAME" -x "Studio One" >/dev/null
}

# Ya está abierto
if is_running; then
  echo "Studio One already running"
  exit 0
fi

# Buscar sesión gráfica viva
GUI_PID="$(pgrep -u "$USER_NAME" -n gnome-shell || true)"
if [ -z "$GUI_PID" ]; then
  GUI_PID="$(pgrep -u "$USER_NAME" -n gnome-session-binary || true)"
fi

if [ -z "$GUI_PID" ]; then
  echo "No active graphical session found for $USER_NAME"
  exit 1
fi

# Cargar variables reales de la sesión gráfica viva
unset DISPLAY WAYLAND_DISPLAY XDG_RUNTIME_DIR DBUS_SESSION_BUS_ADDRESS XAUTHORITY QT_QPA_PLATFORM

while IFS= read -r line; do
  case "$line" in
    DISPLAY=*|WAYLAND_DISPLAY=*|XDG_RUNTIME_DIR=*|DBUS_SESSION_BUS_ADDRESS=*|XAUTHORITY=*)
      export "$line"
      ;;
  esac
done < <(tr '\0' '\n' < "/proc/$GUI_PID/environ")

# Completar faltantes comunes
if [ -z "${XDG_RUNTIME_DIR:-}" ]; then
  export XDG_RUNTIME_DIR="/run/user/1000"
fi

if [ -z "${DBUS_SESSION_BUS_ADDRESS:-}" ]; then
  export DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR}/bus"
fi

if [ -z "${XAUTHORITY:-}" ]; then
  XAUTH_CANDIDATE="$(ls "${XDG_RUNTIME_DIR}"/.mutter-Xwaylandauth.* 2>/dev/null | head -n1 || true)"
  if [ -n "$XAUTH_CANDIDATE" ]; then
    export XAUTHORITY="$XAUTH_CANDIDATE"
  fi
fi

export QT_QPA_PLATFORM=xcb

nohup "$APP" >"$LOG_FILE" 2>&1 </dev/null &
sleep 8

if is_running; then
  echo "Studio One running"
  exit 0
fi

echo "Studio One failed"
echo "--- ENV ---"
env | grep -E 'DISPLAY|WAYLAND_DISPLAY|XDG_RUNTIME_DIR|DBUS_SESSION_BUS_ADDRESS|XAUTHORITY|QT_QPA_PLATFORM' || true
echo "--- LOG ---"
cat "$LOG_FILE" 2>/dev/null || true
exit 1