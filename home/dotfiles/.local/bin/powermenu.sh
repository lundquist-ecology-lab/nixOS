#!/usr/bin/env bash

# Power menu using rofi with paradise theme

options="  Lock\n  Logout\n  Suspend\n  Reboot\n  Shutdown"

chosen=$(echo -e "$options" | rofi -dmenu -i -p "Power Menu" -theme ~/.config/rofi/paradise-power.rasi)

lock_session() {
    if command -v hyprlock >/dev/null 2>&1; then
        hyprlock
    elif command -v swaylock >/dev/null 2>&1; then
        swaylock
    else
        if [ -n "${XDG_SESSION_ID:-}" ]; then
            loginctl lock-session "$XDG_SESSION_ID"
        else
            loginctl lock-user "$(whoami)"
        fi
    fi
}

logout_session() {
    case "${XDG_SESSION_DESKTOP:-}" in
        Hyprland)
            hyprctl dispatch exit
            ;;
        niri)
            niri msg action quit --skip-confirmation
            ;;
        *)
            if [ -n "${XDG_SESSION_ID:-}" ]; then
                loginctl terminate-session "$XDG_SESSION_ID"
            else
                loginctl terminate-user "$(whoami)"
            fi
            ;;
    esac
}

case $chosen in
    *Lock)
        lock_session
        ;;
    *Logout)
        logout_session
        ;;
    *Suspend)
        systemctl suspend
        ;;
    *Reboot)
        systemctl reboot
        ;;
    *Shutdown)
        systemctl poweroff
        ;;
esac
