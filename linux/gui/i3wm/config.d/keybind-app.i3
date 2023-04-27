# start a terminal
bindsym $mod+Return exec konsole

# focused window
bindsym $mod+Shift+q kill

# start rofi
bindsym $mod+d exec --no-startup-id rofi -show combi

# Clipboard manager 
bindsym $mod+c exec --no-startup-id rofi -modi "clipboard:greenclip print" -show clipboard

# Volume Control
set $VolumeUp_CMD "pactl set-sink-volume @DEFAULT_SINK@ +1%"
set $VolumeDown_CMD "pactl set-sink-volume @DEFAULT_SINK@ -1%"
bindsym XF86AudioRaiseVolume exec --no-startup-id $VolumeUp_CMD
bindsym XF86AudioLowerVolume exec --no-startup-id $VolumeDown_CMD
bindsym Ctrl+Shift+Up exec --no-startup-id $VolumeUp_CMD
bindsym Ctrl+Shift+Down exec --no-startup-id $VolumeDown_CMD
bindsym XF86AudioMute exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle
bindsym XF86AudioMicMute exec --no-startup-id pactl set-source-mute @DEFAULT_SOURCE@ toggle
