# Boot-time session choice: the "Arch Linux (linux-zen, Hyprland)" systemd-boot
# entry passes navi.session=hyprland on the kernel cmdline. On tty1 that starts
# Hyprland. Any other boot leaves the startx/xinitrc path untouched.
if [[ "$(tty)" == /dev/tty1 && -z "$WAYLAND_DISPLAY$DISPLAY" ]] && grep -qw navi.session=hyprland /proc/cmdline; then
	exec start-hyprland
fi
