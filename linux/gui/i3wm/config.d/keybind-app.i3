# start a terminal
bindsym $mod+Return exec konsole

# focused window
bindsym $mod+Shift+q kill

# start rofi
bindsym $mod+d exec --no-startup-id rofi -show combi

# Clipboard manager 
bindsym $mod+c exec --no-startup-id rofi -modi "clipboard:greenclip print" -show clipboard
