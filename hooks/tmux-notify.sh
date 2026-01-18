#!/bin/bash
# Hook: Notify tmux when Claude completes a task
# Triggers: visual bell, window flag, and optional desktop notification

# Only run if inside tmux
if [[ -n "$TMUX" ]]; then
    # Set window alert flag (shows * in window list)
    tmux set-window-option -q alert-activity on

    # Trigger visual/audible bell (shows ! in status bar)
    printf '\a'

    # Optional: Set custom window status to show completion icon
    # tmux set-window-option -q window-status-current-format '#I:#{?window_zoomed_flag,🔍,}#W🤖'

    # Optional: Send desktop notification (if notify-send available)
    if command -v notify-send &>/dev/null; then
        notify-send -t 3000 "Claude Code" "Task complete - awaiting input"
    fi
fi

exit 0
