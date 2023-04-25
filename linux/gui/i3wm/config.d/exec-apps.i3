# Start XDG autostart .desktop files using dex. See also
# https://wiki.archlinux.org/index.php/XDG_Autostart
exec --no-startup-id dex --autostart --environment i3

# The combination of xss-lock, nm-applet and pactl is a popular choice, so
# they are included here as an example. Modify as you see fit.

# xss-lock grabs a logind suspend inhibit lock and will use i3lock to lock the
# screen before suspend. Use loginctl lock-session to lock your screen.
exec --no-startup-id xss-lock --transfer-sleep-lock -- i3lock --nofork

# NetworkManager is the most popular way to manage wireless networks on Linux,
# and nm-applet is a desktop environment-independent system tray GUI for it.
exec --no-startup-id nm-applet

# Start polybar
exec_always --no-startup-id "${HOME}/.config/polybar/launch.sh"

# Set wallpaper
exec --no-startup-id "feh --bg-scale ~/.wallpapers/Sayaka.jpg"

# start clipboard manager
exec --no-startup-id greenclip daemon > /dev/null

# start keyring daemon
exec --no-startup-id /usr/bin/gnome-keyring-daemon --start --components=ssh,secrets,pkcs11

# xfce4-screenshooterでクリップボードを使うためにxfce4-clipmanを起動
exec --no-startup-id xfce4-clipman &

